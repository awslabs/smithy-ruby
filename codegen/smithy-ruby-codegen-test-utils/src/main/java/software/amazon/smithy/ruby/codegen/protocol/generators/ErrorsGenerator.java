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

package software.amazon.smithy.ruby.codegen.protocol.generators;

import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.generators.ErrorsGeneratorBase;

/**
 * TestProtocol ErrorGenerator.
 */
public class ErrorsGenerator extends ErrorsGeneratorBase {

    /**
     * @param context generation context
     */
    public ErrorsGenerator(GenerationContext context) {
        super(context);
    }

    public void renderErrorCodeBody() {
        writer.write("resp.headers['x-smithy-error']");
    }
}
