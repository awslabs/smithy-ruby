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

import java.util.Collection;
import java.util.Comparator;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import software.amazon.smithy.build.FileManifest;
import software.amazon.smithy.codegen.core.Symbol;
import software.amazon.smithy.codegen.core.SymbolProvider;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.neighbor.Walker;
import software.amazon.smithy.model.shapes.BlobShape;
import software.amazon.smithy.model.shapes.ListShape;
import software.amazon.smithy.model.shapes.MapShape;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeVisitor;
import software.amazon.smithy.model.shapes.StringShape;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.shapes.UnionShape;
import software.amazon.smithy.model.traits.IdempotencyTokenTrait;
import software.amazon.smithy.model.traits.SparseTrait;
import software.amazon.smithy.model.traits.StreamingTrait;
import software.amazon.smithy.model.transform.ModelTransformer;
import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.Hearth;
import software.amazon.smithy.ruby.codegen.RubyCodeWriter;
import software.amazon.smithy.ruby.codegen.RubyFormatter;
import software.amazon.smithy.ruby.codegen.RubyImportContainer;
import software.amazon.smithy.ruby.codegen.RubySettings;
import software.amazon.smithy.ruby.codegen.RubySymbolProvider;
import software.amazon.smithy.utils.SmithyInternalApi;

@SmithyInternalApi
public class ParamsGenerator extends ShapeVisitor.Default<Void> {
    private static final Logger LOGGER =
            Logger.getLogger(ParamsGenerator.class.getName());

    private final GenerationContext context;
    private final RubySettings settings;
    private final Model model;
    private final RubyCodeWriter writer;
    private final SymbolProvider symbolProvider;

    public ParamsGenerator(GenerationContext context) {
        this.context = context;
        this.settings = context.settings();
        this.model = context.model();
        this.writer = new RubyCodeWriter(context.settings().getModule() + "::Params");
        this.symbolProvider = new RubySymbolProvider(model, settings, "Params", true);
    }

    public void render() {
        FileManifest fileManifest = context.fileManifest();

        writer
                .includePreamble()
                .includeRequires()
                .openBlock("module $L", settings.getModule())
                .openBlock("module Params")
                .call(() -> renderParams())
                .write("")
                .closeBlock("end")
                .closeBlock("end");

        String fileName =
                settings.getGemName() + "/lib/" + settings.getGemName()
                        + "/params.rb";
        fileManifest.writeFile(fileName, writer.toString());
        LOGGER.fine("Wrote params to " + fileName);
    }

    private void renderParams() {
        Model modelWithoutTraitShapes = ModelTransformer.create()
                .getModelWithoutTraitShapes(model);

        new Walker(modelWithoutTraitShapes)
                .walkShapes(context.service())
                .stream()
                .sorted(Comparator.comparing((o) -> o.getId().getName()))
                .forEach((shape) -> shape.accept(this));
    }

    @Override
    protected Void getDefault(Shape shape) {
        return null;
    }

    @Override
    public Void structureShape(StructureShape structureShape) {

        writer
                .write("")
                .openBlock("module $T", symbolProvider.toSymbol(structureShape))
                .openBlock("def self.build(params, context: '')")
                .call(() -> renderBuilderForStructureMembers(
                        context.symbolProvider().toSymbol(structureShape), structureShape.members()))
                .closeBlock("end")
                .closeBlock("end");
        return null;
    }

    private void renderBuilderForStructureMembers(Symbol symbol, Collection<MemberShape> members) {
        writer
                .write("$T.validate!(params, ::Hash, $T, context: context)",
                        Hearth.VALIDATOR, symbol)
                .write("type = $T.new", symbol);

        members.forEach(member -> {
            Shape target = model.expectShape(member.getTarget());
            String memberName = symbolProvider.toMemberName(member);
            String memberSetter = "type." + memberName + " = ";
            String symbolName = RubyFormatter.asSymbol(memberName);
            String input = "params[" + symbolName + "]";
            String context = "\"#{context}[" + symbolName + "]\"";
            target.accept(new MemberBuilder(writer, symbolProvider,
                    memberSetter, input, context, member, true));
        });

        writer.write("type");
    }

    @Override
    public Void listShape(ListShape listShape) {
        Shape memberTarget =
                model.expectShape(listShape.getMember().getTarget());

        writer
                .write("")
                .openBlock("module $T", symbolProvider.toSymbol(listShape))
                .openBlock("def self.build(params, context: '')")
                .write("$T.validate!(params, ::Array, context: context)", Hearth.VALIDATOR)
                .write("data = []")
                .call(() -> {
                    if (isComplexShape(memberTarget)) {
                        writer.openBlock("params.each_with_index do |element, index|");
                    } else {
                        writer.openBlock("params.each do |element|");
                    }
                })
                .call(() -> memberTarget
                        .accept(new MemberBuilder(writer, symbolProvider, "data << ", "element",
                                "\"#{context}[#{index}]\"",
                                listShape.getMember(),
                                !listShape.hasTrait(SparseTrait.class))))
                .closeBlock("end")
                .write("data")
                .closeBlock("end")
                .closeBlock("end");
        return null;
    }

    @Override
    public Void mapShape(MapShape mapShape) {
        Shape valueTarget = model.expectShape(mapShape.getValue().getTarget());

        writer
                .write("")
                .openBlock("module $T", symbolProvider.toSymbol(mapShape))
                .openBlock("def self.build(params, context: '')")
                .write("$T.validate!(params, ::Hash, context: context)", Hearth.VALIDATOR)
                .write("data = {}")
                .openBlock("params.each do |key, value|")
                .call(() -> valueTarget
                        .accept(new MemberBuilder(writer, symbolProvider, "data[key] = ", "value",
                                "\"#{context}[:#{key}]\"", mapShape.getValue(), !
                                mapShape.hasTrait(SparseTrait.class))))
                .closeBlock("end")
                .write("data")
                .closeBlock("end")
                .closeBlock("end");
        return null;
    }

    @Override
    public Void unionShape(UnionShape shape) {
        Symbol symbol = symbolProvider.toSymbol(shape);
        Symbol typeSymbol = context.symbolProvider().toSymbol(shape);

        writer
                .write("")
                .openBlock("module $T", symbol)
                .openBlock("def self.build(params, context: '')")
                .write("return params if params.is_a?($T)", typeSymbol)
                .write("$T.validate!(params, ::Hash, $T, context: context)",
                        Hearth.VALIDATOR, typeSymbol)
                .openBlock("unless params.size == 1")
                .write("raise ArgumentError,")
                .indent(3)
                .write("\"Expected #{context} to have exactly one member, got: #{params}\"")
                .dedent(3)
                .closeBlock("end")
                .write("key, value = params.flatten")
                .write("case key"); //start a case statement.  This does NOT indent

        for (MemberShape member : shape.members()) {
            Shape target = model.expectShape(member.getTarget());
            String memberClassName = symbolProvider.toMemberName(member);
            String memberName = RubyFormatter.asSymbol(memberClassName);
            writer.write("when $L", memberName)
                    .indent()
                    .openBlock("$T.new(", context.symbolProvider().toSymbol(member));
            String input = "params[" + memberName + "]";
            String context = "\"#{context}[" + memberName + "]\"";
            target.accept(new MemberBuilder(writer, symbolProvider, "", input, context, member, false));
            writer.closeBlock(")")
                    .dedent();
        }
        String expectedMembers =
                shape.members().stream().map((member) -> RubyFormatter.asSymbol(member.getMemberName()))
                        .collect(Collectors.joining(", "));
        writer.write("else")
                .indent()
                .write("raise ArgumentError,")
                .indent(3)
                .write("\"Expected #{context} to have one of $L set\"", expectedMembers)
                .dedent(4);
        writer.write("end")  //end of case statement, NOT indented
                .closeBlock("end")
                .closeBlock("end");
        return null;
    }

    private boolean isComplexShape(Shape shape) {
        return shape.isStructureShape() || shape.isListShape() || shape.isMapShape()
                || shape.isUnionShape() || shape.isOperationShape();
    }

    private static class MemberBuilder extends ShapeVisitor.Default<Void> {
        private final RubyCodeWriter writer;
        private final SymbolProvider symbolProvider;
        private final String memberSetter;
        private final String input;
        private final String context;
        private final MemberShape memberShape;
        private final boolean checkRequired;

        MemberBuilder(RubyCodeWriter writer, SymbolProvider symbolProvider, String memberSetter, String input,
                      String context, MemberShape memberShape, boolean checkRequired) {
            this.writer = writer;
            this.symbolProvider = symbolProvider;
            this.memberSetter = memberSetter;
            this.input = input;
            this.context = context;
            this.memberShape = memberShape;
            this.checkRequired = checkRequired;
        }

        @Override
        protected Void getDefault(Shape shape) {
            writer.write("$1L$2L", memberSetter, input);
            return null;
        }

        @Override
        public Void blobShape(BlobShape shape) {
            if (shape.hasTrait(StreamingTrait.class)) {
                writer
                        .write("io = $L || StringIO.new", input)
                        .openBlock("unless io.respond_to?(:read) "
                                + "|| io.respond_to?(:readpartial)")
                        .write("io = StringIO.new(io)")
                        .closeBlock("end")
                        .write("$Lio", memberSetter);
            } else {
                getDefault(shape);
            }
            return null;
        }

        @Override
        public Void stringShape(StringShape shape) {
            if (memberShape.hasTrait(IdempotencyTokenTrait.class)
                    || shape.hasTrait(IdempotencyTokenTrait.class)) {
                writer.write("$L$L || $T.uuid", memberSetter, input, RubyImportContainer.SECURE_RANDOM);
            } else {
                writer.write("$L$L", memberSetter, input);
            }
            return null;
        }

        @Override
        public Void listShape(ListShape shape) {
            defaultComplex(shape);
            return null;
        }

        @Override
        public Void mapShape(MapShape shape) {
            defaultComplex(shape);
            return null;
        }

        @Override
        public Void structureShape(StructureShape shape) {
            defaultComplex(shape);
            return null;
        }

        @Override
        public Void unionShape(UnionShape shape) {
            defaultComplex(shape);
            return null;
        }

        private void defaultComplex(Shape shape) {
            if (checkRequired) {
                writer.write("$1L$2T.build($3L, context: $4L) unless $3L.nil?", memberSetter,
                        symbolProvider.toSymbol(shape), input, context);
            } else {
                writer.write("$1L($2T.build($3L, context: $4L) unless $3L.nil?)", memberSetter,
                        symbolProvider.toSymbol(shape), input, context);
            }
        }
    }
}
