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

import software.amazon.smithy.build.PluginContext;
import software.amazon.smithy.build.SmithyBuildPlugin;
import software.amazon.smithy.codegen.core.ShapeGenerationOrder;
import software.amazon.smithy.codegen.core.directed.CodegenDirector;
import software.amazon.smithy.utils.SmithyInternalApi;

/**
 * Plugin to trigger Ruby code generation.
 */
@SmithyInternalApi
public class DirectedRubyCodegenPlugin implements SmithyBuildPlugin {
    @Override
    public String getName() {
        return "ruby-codegen";
    }

    @Override
    public void execute(PluginContext context) {
        CodegenDirector<RubyCodeWriter, RubyIntegration, GenerationContext, RubySettings> runner
                = new CodegenDirector<>();

        runner.directedCodegen(new DirectedRubyCodegen());

        runner.integrationClass(RubyIntegration.class);

        runner.fileManifest(context.getFileManifest());

        runner.model(context.getModel());

        RubySettings settings = RubySettings.from(context.getSettings());

        runner.settings(settings);

        runner.service(settings.getService());

        runner.performDefaultCodegenTransforms();

        runner.createDedicatedInputsAndOutputs();

        runner.shapeGenerationOrder(ShapeGenerationOrder.ALPHABETICAL);

        runner.run();
    }
}
