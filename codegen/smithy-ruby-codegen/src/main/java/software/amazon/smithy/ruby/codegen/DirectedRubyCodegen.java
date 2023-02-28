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

package software.amazon.smithy.ruby.codegen;

import java.util.Collection;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import software.amazon.smithy.codegen.core.SymbolProvider;
import software.amazon.smithy.codegen.core.directed.CreateContextDirective;
import software.amazon.smithy.codegen.core.directed.CreateSymbolProviderDirective;
import software.amazon.smithy.codegen.core.directed.CustomizeDirective;
import software.amazon.smithy.codegen.core.directed.DirectedCodegen;
import software.amazon.smithy.codegen.core.directed.GenerateEnumDirective;
import software.amazon.smithy.codegen.core.directed.GenerateErrorDirective;
import software.amazon.smithy.codegen.core.directed.GenerateIntEnumDirective;
import software.amazon.smithy.codegen.core.directed.GenerateServiceDirective;
import software.amazon.smithy.codegen.core.directed.GenerateStructureDirective;
import software.amazon.smithy.codegen.core.directed.GenerateUnionDirective;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.shapes.ServiceShape;
import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.ruby.codegen.config.ClientConfig;
import software.amazon.smithy.ruby.codegen.generators.ClientGenerator;
import software.amazon.smithy.ruby.codegen.generators.ConfigGenerator;
import software.amazon.smithy.ruby.codegen.generators.EnumGenerator;
import software.amazon.smithy.ruby.codegen.generators.GemspecGenerator;
import software.amazon.smithy.ruby.codegen.generators.HttpProtocolTestGenerator;
import software.amazon.smithy.ruby.codegen.generators.IntEnumGenerator;
import software.amazon.smithy.ruby.codegen.generators.ModuleGenerator;
import software.amazon.smithy.ruby.codegen.generators.PaginatorsGenerator;
import software.amazon.smithy.ruby.codegen.generators.ParamsGenerator;
import software.amazon.smithy.ruby.codegen.generators.StructureGenerator;
import software.amazon.smithy.ruby.codegen.generators.TypesFileBlockGenerator;
import software.amazon.smithy.ruby.codegen.generators.UnionGenerator;
import software.amazon.smithy.ruby.codegen.generators.ValidatorsGenerator;
import software.amazon.smithy.ruby.codegen.generators.WaitersGenerator;
import software.amazon.smithy.ruby.codegen.generators.YardOptsGenerator;
import software.amazon.smithy.ruby.codegen.middleware.MiddlewareBuilder;

public class DirectedRubyCodegen
    implements DirectedCodegen<GenerationContext, RubySettings, RubyIntegration> {

    private static final Logger LOGGER =
            Logger.getLogger(DirectedRubyCodegen.class.getName());

    private TypesFileBlockGenerator typesFileBlockGenerator;

    @Override
    public SymbolProvider createSymbolProvider(CreateSymbolProviderDirective<RubySettings> directive) {
        return new RubySymbolProvider(directive.model(), directive.settings());
    }

    @Override
    public GenerationContext createContext(CreateContextDirective<RubySettings, RubyIntegration> directive) {
        ServiceShape service = directive.service();
        Model model = directive.model();
        List<RubyIntegration> integrations = directive.integrations();

        Map<ShapeId, ProtocolGenerator> supportedProtocols = ProtocolGenerator
            .collectSupportedProtocolGenerators(integrations);

        ShapeId protocol = directive.settings()
            .resolveServiceProtocol(service, model, supportedProtocols.keySet());

        Optional<ProtocolGenerator> protocolGenerator =
            ProtocolGenerator.resolve(protocol, integrations);

        ApplicationTransport applicationTransport;

        if (protocolGenerator.isPresent()) {
            applicationTransport =
                protocolGenerator.get().getApplicationTransport();
        } else {
            applicationTransport = ApplicationTransport
                .createDefaultHttpApplicationTransport();
        }

        GenerationContext context = new GenerationContext(
            directive.settings(),
            directive.fileManifest(),
            integrations,
            model,
            service,
            protocol,
            protocolGenerator,
            applicationTransport,
            collectDependencies(model, service, protocol, directive.settings(), integrations),
            directive.symbolProvider());

        return context;
    }

    @Override
    public void generateService(GenerateServiceDirective<GenerationContext, RubySettings> directive) {
        GenerationContext context = directive.context();
        // Register all middleware
        MiddlewareBuilder middlewareBuilder = new MiddlewareBuilder();
        middlewareBuilder.addDefaultMiddleware(context);

        context.integrations().forEach((integration) -> {
            integration.modifyClientMiddleware(middlewareBuilder, context);
        });

        context.protocolGenerator().ifPresent((g) -> g.modifyClientMiddleware(middlewareBuilder, context));

        // get all config
        Set<ClientConfig> unorderedConfig = new HashSet<>();
        context.applicationTransport().getClientConfig().forEach((c) -> c.addToConfigCollection(unorderedConfig));
        middlewareBuilder.getClientConfig(context).forEach((c) -> c.addToConfigCollection(unorderedConfig));

        context.integrations().forEach((i) -> {
            i.getAdditionalClientConfig(context).forEach((c) -> c.addToConfigCollection(unorderedConfig));
        });
        context.protocolGenerator().ifPresent((g) -> {
            g.getAdditionalClientConfig(context).forEach((c) -> c.addToConfigCollection(unorderedConfig));
        });

        List<ClientConfig> clientConfigList = unorderedConfig.stream()
                .sorted(Comparator.comparing(ClientConfig::getName))
                .collect(Collectors.toList());

        LOGGER.fine("Client config: "
                + clientConfigList.stream().map((m) -> m.toString()).collect(Collectors.joining(",")));

        ConfigGenerator configGenerator = new ConfigGenerator(directive, clientConfigList);
        configGenerator.render();
        configGenerator.renderRbs();
        LOGGER.info("generated config");

        ClientGenerator clientGenerator = new ClientGenerator(directive, middlewareBuilder);
        clientGenerator.render();
        clientGenerator.renderRbs();
        LOGGER.info("generated client");

        WaitersGenerator waitersGenerator = new WaitersGenerator(directive);
        waitersGenerator.render();
        waitersGenerator.renderRbs();
    }

    @Override
    public void customizeBeforeShapeGeneration(CustomizeDirective<GenerationContext, RubySettings> directive) {
        this.typesFileBlockGenerator = new TypesFileBlockGenerator(directive);

        // Pre-populate module blocks for types.rb and types.rbs files
        this.typesFileBlockGenerator.openBlocks();
    }

    @Override
    public void generateStructure(GenerateStructureDirective<GenerationContext, RubySettings> directive) {
        new StructureGenerator(directive).render();
    }

    @Override
    public void generateError(GenerateErrorDirective<GenerationContext, RubySettings> directive) {
        if (directive.context().protocolGenerator().isPresent()) {
            directive.context().protocolGenerator().get().generateErrors(directive.context());
        }
        new StructureGenerator(directive).render();
    }

    @Override
    public void generateUnion(GenerateUnionDirective<GenerationContext, RubySettings> directive) {
        new UnionGenerator(directive).render();
    }

    @Override
    public void generateEnumShape(GenerateEnumDirective<GenerationContext, RubySettings> directive) {
        new EnumGenerator(directive).render();
    }

    @Override
    public void generateIntEnumShape(GenerateIntEnumDirective<GenerationContext, RubySettings> directive) {
        new IntEnumGenerator(directive).render();
    }

    @Override
    public void customizeBeforeIntegrations(CustomizeDirective<GenerationContext, RubySettings> directive) {
        GenerationContext context = directive.context();
        new ParamsGenerator(directive).render();
        new ValidatorsGenerator(directive).render();

        if (directive.context().protocolGenerator().isPresent()) {
            ProtocolGenerator generator = directive.context().protocolGenerator().get();
            generator.generateBuilders(directive.context());
            generator.generateParsers(directive.context());
            generator.generateStubs(directive.context());
        }

        PaginatorsGenerator paginatorsGenerator = new PaginatorsGenerator(directive);
        paginatorsGenerator.render();
        paginatorsGenerator.renderRbs();

        new ModuleGenerator(directive).render();
        new GemspecGenerator(context).render();
        new YardOptsGenerator(context).render();

        if (context.applicationTransport().isHttpTransport()) {
            HttpProtocolTestGenerator testGenerator =
                    new HttpProtocolTestGenerator(context);
            testGenerator.render();
        }
    }

    @Override
    public void customizeAfterIntegrations(CustomizeDirective<GenerationContext, RubySettings> directive) {
        // Close all module blocks for types.rb and types.rbs files
        this.typesFileBlockGenerator.closeAllBlocks();
    }

    private Set<RubyDependency> collectDependencies(
        Model model,
        ServiceShape service,
        ShapeId protocol,
        RubySettings settings,
        List<RubyIntegration> integrations
    ) {
        Set<RubyDependency> rubyDependencies = new HashSet<>();
        rubyDependencies.addAll(settings.getBaseDependencies());
        rubyDependencies.addAll(
            integrations.stream()
                .map((integration) -> integration
                        .additionalGemDependencies(settings, model, service, protocol))
                .flatMap(Collection::stream)
                .collect(Collectors.toSet())
        );

        return rubyDependencies;
    }
}
