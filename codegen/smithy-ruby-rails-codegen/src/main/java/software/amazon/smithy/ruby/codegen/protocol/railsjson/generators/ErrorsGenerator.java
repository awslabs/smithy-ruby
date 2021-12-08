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

package software.amazon.smithy.ruby.codegen.protocol.railsjson.generators;

import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.generators.ErrorsGeneratorBase;
import software.amazon.smithy.ruby.codegen.traits.RailsJsonTrait;

public class ErrorsGenerator extends ErrorsGeneratorBase {

    public ErrorsGenerator(GenerationContext context) {
        super(context);
    }

    public void renderErrorCode() {
        RailsJsonTrait railsJsonTrait = context.getService().getTrait(RailsJsonTrait.class).get();
        String errorLocation = railsJsonTrait.getErrorLocation().orElse("status_code");

        writer.openBlock("def self.error_code(http_resp)");

        if (errorLocation.equals("header")) {
            renderErrorCodeFromHeader();
        } else if (errorLocation.equals("status_code")) {
            renderErrorCodeFromStatusCode();
        }

        writer.closeBlock("end");
    }

    private void renderErrorCodeFromHeader() {
        writer.write("http_resp.headers['x-smithy-rails-error']");
    }

    private void renderErrorCodeFromStatusCode() {
        writer
                .write("case http_resp.status")
                .write("when 404 then 'NotFoundError'")
                .write("when 422 then 'UnprocessableEntityError'")
                .write("end");
    }
}
