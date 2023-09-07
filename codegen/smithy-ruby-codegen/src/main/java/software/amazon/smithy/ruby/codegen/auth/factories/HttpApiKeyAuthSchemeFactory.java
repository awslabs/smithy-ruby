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

package software.amazon.smithy.ruby.codegen.auth.factories;

import software.amazon.smithy.model.traits.HttpApiKeyAuthTrait;
import software.amazon.smithy.ruby.codegen.Hearth;
import software.amazon.smithy.ruby.codegen.auth.AuthScheme;
import software.amazon.smithy.ruby.codegen.config.ClientConfig;

public final class HttpApiKeyAuthSchemeFactory {
    private HttpApiKeyAuthSchemeFactory() {
    }

    public static AuthScheme build() {
        String identityResolverDocumentation = """
                A %s that returns a %s for operations modeled with the %s auth scheme.
                """;

        String defaultIdentity = Hearth.IDENTITIES + "::HTTPApiKey.new(key: 'stubbed api key')";
        String defaultConfigValue = "proc { |cfg| cfg[:stub_responses] ? %s.new(proc { %s }) : nil }"
                .formatted(Hearth.IDENTITY_RESOLVER, defaultIdentity);

        ClientConfig identityResolverConfig = ClientConfig.builder()
                .name("http_api_key_identity_resolver")
                .type(Hearth.IDENTITY_RESOLVER.toString())
                .documentation(
                        identityResolverDocumentation.formatted(
                                Hearth.IDENTITY_RESOLVER,
                                Hearth.IDENTITIES + "::HTTPApiKey",
                                HttpApiKeyAuthTrait.ID))
                .defaultDynamicValue(defaultConfigValue)
                .allowOperationOverride()
                .build();

        return AuthScheme.builder()
                .shapeId(HttpApiKeyAuthTrait.ID)
                .rubyAuthScheme(Hearth.AUTH_SCHEMES + "::HTTPApiKey.new")
                .identityResolverConfig(identityResolverConfig)
                .build();
    }
}
