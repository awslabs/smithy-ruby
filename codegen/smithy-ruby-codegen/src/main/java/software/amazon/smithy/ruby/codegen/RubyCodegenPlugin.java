/*
 * Copyright 2020 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

import java.util.logging.Logger;
import software.amazon.smithy.build.PluginContext;
import software.amazon.smithy.build.SmithyBuildPlugin;
import software.amazon.smithy.utils.SmithyInternalApi;

@SmithyInternalApi
public final class RubyCodegenPlugin implements SmithyBuildPlugin {
    private static final Logger LOGGER =
            Logger.getLogger(RubyCodegenPlugin.class.getName());

    @Override
    public String getName() {
        return "ruby-codegen";
    }

    @Override
    public void execute(PluginContext context) {
        (new CodegenOrchestrator(context)).execute();
    }
}

