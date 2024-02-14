/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

package software.amazon.smithy.ruby.codegen.generators;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import software.amazon.smithy.build.SmithyBuildException;
import software.amazon.smithy.codegen.core.directed.ContextualDirective;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.ServiceShape;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.Hearth;
import software.amazon.smithy.ruby.codegen.RubyCodeWriter;
import software.amazon.smithy.ruby.codegen.RubyFormatter;
import software.amazon.smithy.ruby.codegen.RubySettings;
import software.amazon.smithy.ruby.codegen.rulesengine.FunctionBinding;
import software.amazon.smithy.rulesengine.language.Endpoint;
import software.amazon.smithy.rulesengine.language.EndpointRuleSet;
import software.amazon.smithy.rulesengine.language.syntax.Identifier;
import software.amazon.smithy.rulesengine.language.syntax.expressions.Expression;
import software.amazon.smithy.rulesengine.language.syntax.expressions.ExpressionVisitor;
import software.amazon.smithy.rulesengine.language.syntax.expressions.Reference;
import software.amazon.smithy.rulesengine.language.syntax.expressions.Template;
import software.amazon.smithy.rulesengine.language.syntax.expressions.TemplateVisitor;
import software.amazon.smithy.rulesengine.language.syntax.expressions.functions.FunctionDefinition;
import software.amazon.smithy.rulesengine.language.syntax.expressions.functions.GetAttr;
import software.amazon.smithy.rulesengine.language.syntax.expressions.literal.Literal;
import software.amazon.smithy.rulesengine.language.syntax.expressions.literal.LiteralVisitor;
import software.amazon.smithy.rulesengine.language.syntax.parameters.Parameter;
import software.amazon.smithy.rulesengine.language.syntax.parameters.ParameterType;
import software.amazon.smithy.rulesengine.language.syntax.rule.Condition;
import software.amazon.smithy.rulesengine.language.syntax.rule.Rule;
import software.amazon.smithy.rulesengine.language.syntax.rule.RuleValueVisitor;
import software.amazon.smithy.rulesengine.traits.ClientContextParamsTrait;
import software.amazon.smithy.rulesengine.traits.ContextParamTrait;
import software.amazon.smithy.rulesengine.traits.EndpointTestsTrait;
import software.amazon.smithy.rulesengine.traits.StaticContextParamDefinition;
import software.amazon.smithy.rulesengine.traits.StaticContextParamsTrait;
import software.amazon.smithy.utils.SmithyInternalApi;

@SmithyInternalApi
public class EndpointGenerator extends RubyGeneratorBase {
    private static final Logger LOGGER =
            Logger.getLogger(EndpointGenerator.class.getName());

    private final Set<OperationShape> operations;
    private final ServiceShape service;
    private final EndpointRuleSet endpointRuleSet;
    private final Optional<EndpointTestsTrait> endpointTests;

    public EndpointGenerator(ContextualDirective<GenerationContext, RubySettings> directive) {
        super(directive);
        operations = directive.operations();
        service = directive.service();
        endpointRuleSet = context.getEndpointRuleSet();
        endpointTests = service.getTrait(EndpointTestsTrait.class);
    }

    @Override
    String getModule() {
        return "Endpoint";
    }

    public void render() {

        // Possible future optimization: only write/require files for functions that are used in this ruleset
        List<String> additionalFiles =
                Stream.concat(
                                context.getBuiltInBindingsFromEndpointRules().stream()
                                        .map(b -> b.writeAdditionalFiles(context))
                                        .flatMap(Collection::stream),
                                context.getFunctionBindings().values().stream()
                                        .map(b -> b.writeAdditionalFiles(context))
                                        .flatMap(Collection::stream)
                        )
                        .distinct()
                        .sorted()
                        .collect(Collectors.toList());

        write(writer -> {
            writer
                    .preamble()
                    .includeRequires()
                    .writeRequireRelativeAdditionalFiles(additionalFiles)
                    .addModule(settings.getModule())
                    .addModule("Endpoint")
                    .call(() -> renderEndpointParamsClass(writer))
                    .write("")
                    .call(() -> renderEndpointResolver(writer))
                    .write("")
                    .addModule("Parameters")
                    .call(() -> renderParamBuilders(writer))
                    .closeModule()
                    .write("")
//                    .call(() -> renderAuthSchemesConstant(writer))
//                    .write("")
//                    .call(() -> renderAuthResolver(writer))
                    .closeAllModules();
        });
        LOGGER.fine("Wrote auth module to " + rbFile());
    }

    public void renderRbs() {
        writeRbs(writer -> {
            writer
                    .preamble()
                    .addModule(settings.getModule())
                    .addModule("Endpoint")
                    .call(() -> renderRbsEndpointParamsClass(writer))
                    .write("")
//                    .call(() -> renderRbsAuthSchemesConstant(writer))
//                    .write("")
//                    .call(() -> renderRbsAuthResolver(writer))
                    .closeAllModules();
        });
        LOGGER.fine("Wrote auth rbs module to " + rbsFile());
    }

    private void renderEndpointParamsClass(RubyCodeWriter writer) {
        List<String> params = new ArrayList<>();
        Map<String, String> defaultParams = new LinkedHashMap<>();
        endpointRuleSet.getParameters().forEach((parameter -> {
            String rubyParamName = RubyFormatter.asSymbol(parameter.getName().getName().getValue());
            params.add(rubyParamName);
            if (parameter.getDefault().isPresent()) {
                if (parameter.getType() == ParameterType.STRING) {
                    defaultParams.put(rubyParamName,
                            "'" + parameter.getDefault().get().expectStringValue().getValue() + "'");
                } else if (parameter.getType() == ParameterType.BOOLEAN) {
                    defaultParams.put(rubyParamName,
                            parameter.getDefault().get().expectBooleanValue().getValue() ? "true" : "false");
                } else {
                    throw new IllegalArgumentException("Unexpected parameter type: " + parameter.getType());
                }
            }
        }));

        writer
                .openBlock("Params = ::Struct.new(")
                .write(String.join(",\n", params) + ", ")
                .write("keyword_init: true")
                .closeBlock(") do")
                .indent()
                .write("include $T", Hearth.STRUCTURE)
                .call(() -> {
                    if (!defaultParams.isEmpty()) {
                        writer
                                .openBlock("\ndef initialize(*)")
                                .write("super")
                                .call(() -> {
                                    defaultParams.forEach((param, defaultValue) -> {
                                        writer.write("self.$1L = $2L if self.$1L.nil?",
                                                param,
                                                defaultValue);
                                    });
                                })
                                .closeBlock("end");
                    }

                })
                .closeBlock("end");
    }

    private void renderRbsEndpointParamsClass(RubyCodeWriter writer) {
        Map<String, String> paramsToTypes = new HashMap<>();
        endpointRuleSet.getParameters().forEach((parameter -> {
            String rubyParamName = RubyFormatter.toSnakeCase(parameter.getName().getName().getValue());
            if (parameter.getType() == ParameterType.STRING) {
                paramsToTypes.put(rubyParamName, "::String");
            } else if (parameter.getType() == ParameterType.BOOLEAN) {
                paramsToTypes.put(rubyParamName, "bool");
            } else {
                throw new IllegalArgumentException("Unexpected parameter type: " + parameter.getType());
            }
        }));

        writer
                .openBlock("class Params < ::Struct[untyped]")
                .call(() -> {
                    paramsToTypes.forEach((param, rbsType) -> {
                        writer.write("attr_accessor $L: $L", param, rbsType);
                    });
                })
                .closeBlock("end");
    }

    private void renderParamBuilders(RubyCodeWriter writer) {
        Map<String, String> clientContextParams = new HashMap<>();
        service.getTrait(ClientContextParamsTrait.class).ifPresent((clientContext) -> {
            clientContext.getParameters().forEach((name, param) -> {
                clientContextParams.put(name, RubyFormatter.toSnakeCase(name));
            });
        });

        for (OperationShape operation : operations) {
            Map<String, StaticContextParamDefinition> staticContextParams = new HashMap<>();
            operation.getTrait(StaticContextParamsTrait.class).ifPresent((staticContext) -> {
                staticContext.getParameters().forEach((name, p) -> {
                    staticContextParams.put(name, p);
                });
            });

            Map<String, String> contextParams = new HashMap<>();
            context.model().expectShape(operation.getInputShape(), StructureShape.class)
                    .getAllMembers().forEach((n, member) -> {
                        member.getMemberTrait(context.model(), ContextParamTrait.class).ifPresent(contextParam -> {
                            contextParams.put(contextParam.getName(), symbolProvider.toMemberName(member));
                        });
                    });
            // Optional<ContextParamTrait> contextParams = operation.getTrait(ContextParamTrait.class);

            writer
                    .write("")
                    .openBlock("class $L", symbolProvider.toSymbol(operation).getName())
                    .openBlock("def self.build(config, input, context)")
                    .write("params = Params.new")
                    .call(() -> {
                        for (Parameter p : endpointRuleSet.getParameters()) {
                            String paramName = p.getName().toString();
                            if (staticContextParams.containsKey(paramName)) {
                                StaticContextParamDefinition def = staticContextParams.get(paramName);
                                String value;
                                if (def.getValue().isStringNode()) {
                                    value = "'" + def.getValue().expectStringNode() + "'";
                                } else if (def.getValue().isBooleanNode()) {
                                    value = def.getValue().expectBooleanNode().getValue() ? "true" : "false";
                                } else {
                                    throw new SmithyBuildException("Unexpected StaticContextParam type: "
                                            + def.getValue().getType() + " for parameter: " + paramName);
                                }
                                writer.write("params.$L = $L",
                                        RubyFormatter.toSnakeCase(paramName), value);
                            } else if (clientContextParams.containsKey(paramName)) {
                                writer.write("params.$1L = config[:$1L]",
                                        clientContextParams.get(paramName));
                            } else if (contextParams.containsKey(paramName)) {
                                writer.write("params.$L = input.$L",
                                        RubyFormatter.toSnakeCase(paramName),
                                        contextParams.get(paramName));
                            } else if (p.isBuiltIn()) {
                                context.getBuiltInBinding(p.getName()).get().renderBuild(writer, context, operation);
                            }
                            // some parameters may not have bindings for an operation, leave them as nil or default
                        }
                    })
                    .write("params")
                    .closeBlock("end")
                    .closeBlock("end");
        }
    }

    private void renderEndpointResolver(RubyCodeWriter writer) {
        writer
                .openBlock("class Provider")
                .openBlock("def resolve_endpoint(params)")
                .call(() -> mapParametersToLocals(writer))
                .write("")
                .call(() -> renderRules(writer, endpointRuleSet.getRules()))
                .write("")
                .write("raise ArgumentError, 'No endpoint could be resolved'")
                .closeBlock("end")
                .closeBlock("end");

    }

    private void renderRules(RubyCodeWriter writer, List<Rule> rules) {
        for (Rule rule : rules) {
            if (!rule.getConditions().isEmpty()) {
                writer
                        .call(() -> renderConditions(writer, rule.getConditions())).indent() // open if block
                        .call(() -> renderRule(writer, rule))
                        .closeBlock("end");
            } else {
                renderRule(writer, rule);
            }
        }
    }

    private void renderRule(RubyCodeWriter writer, Rule rule) {
        rule.accept(new RenderRuleVisitor(writer));
    }

    private void renderConditions(RubyCodeWriter writer, List<Condition> conditions) {

        String condition = conditions.stream().map((c) -> {
            if (c.getResult().isPresent()) {
                return "(" + c.getResult().get().getName().getValue()
                        + " = " + c.getFunction().accept(new ExpressionTemplateVisitor(context)) + ")";
            } else {
                return "(" + c.getFunction().accept(new ExpressionTemplateVisitor(context)) + ")";
            }
        }).collect(Collectors.joining(" && "));
        writer.write("if $L", condition);
    }

    private void mapParametersToLocals(RubyCodeWriter writer) {
        for (Parameter parameter : endpointRuleSet.getParameters()) {
            writer.write("$1L = params.$1L", RubyFormatter.toSnakeCase(parameter.getName().toString()));
        }
    }

    private String templateExpression(Expression expression) {
        return expression.accept(new ExpressionTemplateVisitor(context));
    }

    private static class ExpressionTemplateVisitor implements ExpressionVisitor<String> {

        final GenerationContext context;

        ExpressionTemplateVisitor(GenerationContext context) {
            this.context = context;
        }

        @Override
        public String visitLiteral(Literal literal) {
            return literal.accept(new TemplateLiteralVisitor(context));
        }

        @Override
        public String visitRef(Reference reference) {
            return RubyFormatter.toSnakeCase(reference.getName().getName().getValue());
        }

        @Override
        public String visitGetAttr(GetAttr getAttr) {
            return "Hearth::RuleSet::get_attr(" + getAttr.getTarget().accept(this) + ")";
        }

        @Override
        public String visitIsSet(Expression expression) {
            return expression.accept(this) + " != nil";
        }

        @Override
        public String visitNot(Expression expression) {
            return "!" + expression.accept(this);
        }

        @Override
        public String visitBoolEquals(Expression expression1, Expression expression2) {
            return expression1.accept(this) + " == "
                    + expression2.accept(this);
        }

        @Override
        public String visitStringEquals(Expression expression1, Expression expression2) {
            return expression1.accept(this) + " == "
                    + expression2.accept(this);
        }

        @Override
        public String visitLibraryFunction(FunctionDefinition functionDefinition, List<Expression> args) {
            FunctionBinding functionBinding = context.getFunctionBinding(functionDefinition.getId())
                    .orElseThrow(() -> new SmithyBuildException(
                            "Unable to find rules engine function binding for: " + functionDefinition.getId()));
            String rubyArgs = args.stream().map((e) -> e.accept(new ExpressionTemplateVisitor(context))).collect(
                    Collectors.joining(", "));
            return functionBinding.getRubyMethodName() + "(" + rubyArgs + ")";
        }
    }

    private static class TemplateLiteralVisitor implements LiteralVisitor<String> {
        final GenerationContext context;

        TemplateLiteralVisitor(GenerationContext context) {
            this.context = context;
        }

        @Override
        public String visitBoolean(boolean b) {
            return b ? "true" : "false";
        }

        @Override
        public String visitString(Template template) {
            return template.accept(new RubyTemplateVisitor(context)).collect(Collectors.joining());
        }

        @Override
        public String visitRecord(Map<Identifier, Literal> map) {
            StringBuilder ret = new StringBuilder();
            ret.append("{");
            ret.append(map.entrySet().stream()
                    .map((e) -> {
                        return e.getKey().getName().getValue() + "=>" + e.getValue().accept(this);
                    })
                    .collect(Collectors.joining(", "))
            );
            ret.append("}");
            return ret.toString();
        }

        @Override
        public String visitTuple(List<Literal> list) {
            String ret = "["
                    + list.stream()
                    .map((l) -> l.accept(this))
                    .collect(Collectors.joining(", "))
                    + "]";
            return ret;
        }

        @Override
        public String visitInteger(int i) {
            return Integer.toString(i);
        }
    }

    private static class RubyTemplateVisitor implements TemplateVisitor<String> {
        final GenerationContext context;

        RubyTemplateVisitor(GenerationContext context) {
            this.context = context;
        }

        @Override
        public String visitStaticTemplate(String s) {
            return "\"" + s + "\"";
        }

        @Override
        public String visitSingleDynamicTemplate(Expression expression) {
            return expression.accept(new ExpressionTemplateVisitor(context));
        }

        @Override
        public String visitStaticElement(String s) {
            return s;
        }

        @Override
        public String visitDynamicElement(Expression expression) {
            return "#{" + expression.accept(new ExpressionTemplateVisitor(context)) + "}";
        }

        @Override
        public String startMultipartTemplate() {
            return "\"";
        }

        @Override
        public String finishMultipartTemplate() {
            return "\"";
        }
    }

    private class RenderRuleVisitor implements RuleValueVisitor<Void> {

        final RubyCodeWriter writer;

        RenderRuleVisitor(RubyCodeWriter writer) {
            this.writer = writer;
        }

        @Override
        public Void visitTreeRule(List<Rule> list) {
            renderRules(writer, list);
            return null;
        }

        @Override
        public Void visitErrorRule(Expression expression) {
            writer.write("raise ArgumentError, $L", expression.accept(new ExpressionTemplateVisitor(context)));
            return null;
        }

        @Override
        public Void visitEndpointRule(Endpoint endpoint) {
            String uriString = templateExpression(endpoint.getUrl());
            writer.write("return $T.new(uri: $L)", Hearth.RULES_ENGINE_ENDPOINT, uriString);
            return null;
        }
    }

}
