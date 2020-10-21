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

package software.amazon.smithy.ruby.codegen.middleware;

import java.util.HashMap;
import software.amazon.smithy.utils.CodeWriter;

public class Middleware {
    private final String klass;
    private final HashMap<String, String> params;

    // params could include any Ruby code
    public Middleware(String klass, HashMap<String, String> params) {
       this.klass = klass;
       this.params = params;
    }

    public void render(CodeWriter writer) {
        writer.write("stack.use($L", klass);
        if (!params.isEmpty()) {
            writer.indent();
            for (HashMap.Entry<String, String> entry : params.entrySet()) {
                writer.write("$L: $L", entry.getKey(), entry.getValue());
            }
            writer.dedent();
        }
        writer.write(")");
    }
}
