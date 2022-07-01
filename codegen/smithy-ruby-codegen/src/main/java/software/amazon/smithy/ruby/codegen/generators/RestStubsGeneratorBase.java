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

import java.util.List;
import java.util.logging.Logger;
import java.util.stream.Collectors;
import software.amazon.smithy.model.shapes.DoubleShape;
import software.amazon.smithy.model.shapes.FloatShape;
import software.amazon.smithy.model.shapes.ListShape;
import software.amazon.smithy.model.shapes.MapShape;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.SetShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeVisitor;
import software.amazon.smithy.model.shapes.StringShape;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.shapes.TimestampShape;
import software.amazon.smithy.model.shapes.UnionShape;
import software.amazon.smithy.model.traits.HttpHeaderTrait;
import software.amazon.smithy.model.traits.HttpLabelTrait;
import software.amazon.smithy.model.traits.HttpPayloadTrait;
import software.amazon.smithy.model.traits.HttpPrefixHeadersTrait;
import software.amazon.smithy.model.traits.HttpQueryParamsTrait;
import software.amazon.smithy.model.traits.HttpQueryTrait;
import software.amazon.smithy.model.traits.HttpResponseCodeTrait;
import software.amazon.smithy.model.traits.HttpTrait;
import software.amazon.smithy.model.traits.MediaTypeTrait;
import software.amazon.smithy.model.traits.TimestampFormatTrait;
import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.util.TimestampFormat;

/**
 * Base class for Stubs for HTTP based protocols.
 * <p>
 * Protocols should extend this class to get common functionality -
 * generates the framework and non-protocol specific parts of
 * stubs.rb.
 */
public abstract class RestStubsGeneratorBase extends StubsGeneratorBase {

    private static final Logger LOGGER =
            Logger.getLogger(RestStubsGeneratorBase.class.getName());

    public RestStubsGeneratorBase(GenerationContext context) {
        super(context);
    }

    /**
     * Called to render an operation's body stubber when it has a Payload member.
     * The generated code should serialize the payloadMember to the response body.
     * The class and build method skeleton is rendered outside of this method
     * and implementations only need to write the stub method body.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class HttpPayloadTraits
     *
     *   def self.default(visited=[])
     *     {
     *       foo: 'foo',
     *       blob: 'blob',
     *     }
     *   end
     *
     *   def self.stub(http_resp, stub:)
     *     http_resp.status = 200
     *     #### START code generated by this method
     *     http_resp.headers['Content-Type'] = 'application/octet-stream'
     *     http_resp.body = StringIO.new(stub[:blob] || '')
     *     #### END code generated by this method
     *   end
     * end
     * }</pre>
     *
     * @param operation     operation to genreate body for
     * @param outputShape   outputShape of the operation
     * @param payloadMember the member marked with payload
     * @param target        the target of the payload member
     */
    protected abstract void renderPayloadBodyStub(OperationShape operation, Shape outputShape,
                                                  MemberShape payloadMember, Shape target);

    /**
     * Called to render an operation's body stubber when it does not have a payload member.
     * The generated code should serialize all of the appropriate outputShapes's members
     * to the requests body (http_resp.body).  This method may also need to set headers
     * such as content type.  The class and build method skeleton is rendered outside of this method
     * and implementations only need to write the stub method body.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class OperationWithOptionalInputOutput
     *
     *   def self.default(visited=[])
     *     {
     *       value: 'value',
     *     }
     *   end
     *
     *   def self.stub(http_resp, stub:)
     *     http_resp.status = 200
     *     http_resp.headers['Content-Type'] = 'application/json'
     *     data = {}
     *     ### START code generated by this method
     *     data[:value] = stub[:value] unless stub[:value].nil?
     *     #### END code generated by this method
     *     http_resp.body = StringIO.new(Hearth::JSON.dump(data))
     *   end
     * end
     * }</pre>
     *
     * @param operation   operation to render for
     * @param outputShape operation's output shape
     */
    protected abstract void renderBodyStub(OperationShape operation, Shape outputShape);

    @Override
    protected void renderOperationStubMethod(OperationShape operation, Shape outputShape) {
        writer
                .openBlock("def self.stub(http_resp, stub:)")
                .write("data = {}")
                .call(() -> renderStatusCodeStubber(operation, outputShape))
                .call(() -> renderHeaderStubbers(operation, outputShape))
                .call(() -> renderPrefixHeadersStubbers(operation, outputShape))
                .call(() -> renderResponseCodeStubber(operation, outputShape))
                .call(() -> renderOperationBodyStubber(operation, outputShape))
                .closeBlock("end");
        LOGGER.finer("Generated stub method for operation " + operation.getId().getName());
    }

    // The Output shape is combined with the OperationStub
    // This generates the setting of the body (if any non-http input) as if it was the Stubber for the Output
    protected void renderOperationBodyStubber(OperationShape operation, Shape outputShape) {
        //determine if there are any members of the input that need to be serialized to the body
        boolean serializeBody = outputShape.members().stream().anyMatch((m) -> !m.hasTrait(HttpLabelTrait.class)
                && !m.hasTrait(HttpQueryTrait.class)
                && !m.hasTrait(HttpQueryParamsTrait.class)
                && !m.hasTrait(HttpHeaderTrait.class)
                && !m.hasTrait(HttpPrefixHeadersTrait.class)
                && !m.hasTrait(HttpResponseCodeTrait.class));
        //determine if there is an httpPayload member
        List<MemberShape> httpPayloadMembers = outputShape.members()
                .stream()
                .filter((m) -> m.hasTrait(HttpPayloadTrait.class))
                .collect(Collectors.toList());
        if (httpPayloadMembers.size() == 0) {
            if (serializeBody) {
                renderBodyStub(operation, outputShape);
            }
        } else {
            MemberShape payloadMember = httpPayloadMembers.get(0);
            Shape target = model.expectShape(payloadMember.getTarget());
            renderPayloadBodyStub(operation, outputShape, payloadMember, target);
        }
    }

    protected void renderStatusCodeStubber(OperationShape operation, Shape outputShape) {
        operation.getTrait(HttpTrait.class).ifPresent((httpTrait) -> {
            writer.write("http_resp.status = $1L", httpTrait.getCode());
        });
    }

    protected void renderHeaderStubbers(OperationShape operation, Shape outputShape) {
        // get a list of all of HttpLabel members
        List<MemberShape> headerMembers = outputShape.members()
                .stream()
                .filter((m) -> m.hasTrait(HttpHeaderTrait.class))
                .collect(Collectors.toList());

        for (MemberShape m : headerMembers) {
            HttpHeaderTrait headerTrait = m.expectTrait(HttpHeaderTrait.class);
            String symbolName = ":" + symbolProvider.toMemberName(m);
            String headerSetter = "http_resp.headers['" + headerTrait.getValue() + "'] = ";
            String valueGetter = "stub[" + symbolName + "]";
            model.expectShape(m.getTarget()).accept(new HeaderSerializer(m, headerSetter, valueGetter));
        }
    }

    protected void renderPrefixHeadersStubbers(OperationShape operation, Shape outputShape) {
        // get a list of all of HttpLabel members
        List<MemberShape> headerMembers = outputShape.members()
                .stream()
                .filter((m) -> m.hasTrait(HttpPrefixHeadersTrait.class))
                .collect(Collectors.toList());

        for (MemberShape m : headerMembers) {
            HttpPrefixHeadersTrait headerTrait = m.expectTrait(HttpPrefixHeadersTrait.class);
            String prefix = headerTrait.getValue();
            // httpPrefixHeaders may only target map shapes
            MapShape targetShape = model.expectShape(m.getTarget(), MapShape.class);
            Shape valueShape = model.expectShape(targetShape.getValue().getTarget());

            String symbolName = ":" + symbolProvider.toMemberName(m);
            String headerSetter = "http_resp.headers[\"" + prefix + "#{key}\"] = ";
            writer
                    .openBlock("stub[$L].each do |key, value|", symbolName)
                    .call(() -> valueShape.accept(new HeaderSerializer(m, headerSetter, "value")))
                    .closeBlock("end");
        }
    }

    protected void renderResponseCodeStubber(OperationShape operation, Shape outputShape) {
        List<MemberShape> responseCodeMembers = outputShape.members()
                .stream()
                .filter((m) -> m.hasTrait(HttpResponseCodeTrait.class))
                .collect(Collectors.toList());

        if (responseCodeMembers.size() == 1) {
            MemberShape responseCodeMember = responseCodeMembers.get(0);
            writer.write("http_resp.status = stub[:$L]", symbolProvider.toMemberName(responseCodeMember));
        }
    }

    private class HeaderSerializer extends ShapeVisitor.Default<Void> {

        private final String inputGetter;
        private final String dataSetter;
        private final MemberShape memberShape;

        HeaderSerializer(MemberShape memberShape,
                         String dataSetter, String inputGetter) {
            this.inputGetter = inputGetter;
            this.dataSetter = dataSetter;
            this.memberShape = memberShape;
        }

        @Override
        protected Void getDefault(Shape shape) {
            writer.write("$1L$2L.to_s unless $2L.nil?", dataSetter, inputGetter);
            return null;
        }

        private void rubyFloat() {
            writer.write("$1LHearth::NumberHelper.serialize($2L) unless $2L.nil?", dataSetter, inputGetter);
        }

        @Override
        public Void doubleShape(DoubleShape shape) {
            rubyFloat();
            return null;
        }

        @Override
        public Void floatShape(FloatShape shape) {
            rubyFloat();
            return null;
        }

        @Override
        public Void stringShape(StringShape shape) {
            // string values with a mediaType trait are always base64 encoded.
            if (shape.hasTrait(MediaTypeTrait.class)) {
                writer.write("$1LBase64::encode64($2L).strip unless $2L.nil? || $2L.empty?", dataSetter, inputGetter);
            } else {
                writer.write("$1L$2L unless $2L.nil? || $2L.empty?", dataSetter, inputGetter);
            }
            return null;
        }

        @Override
        public Void timestampShape(TimestampShape shape) {
            writer.write("$1L$2L unless $3L.nil?",
                    dataSetter,
                    TimestampFormat.serializeTimestamp(
                            shape, memberShape, inputGetter, TimestampFormatTrait.Format.DATE_TIME, false),
                    inputGetter);
            return null;
        }

        @Override
        public Void listShape(ListShape shape) {
            writer.openBlock("unless $1L.nil? || $1L.empty?", inputGetter)
                    .write("$1L$2L", dataSetter, inputGetter)
                    .indent()
                    .write(".compact")
                    .call(() -> model.expectShape(shape.getMember().getTarget())
                            .accept(new HeaderListMemberSerializer(shape.getMember())))
                    .write(".join(', ')")
                    .dedent()
                    .closeBlock("end");
            return null;
        }

        @Override
        public Void setShape(SetShape shape) {
            writer.openBlock("unless $1L.nil? || $1L.empty?", inputGetter)
                    .write("$1L$2L", dataSetter, inputGetter)
                    .indent()
                    .write(".to_a")
                    .write(".compact")
                    .call(() -> model.expectShape(shape.getMember().getTarget())
                            .accept(new HeaderListMemberSerializer(shape.getMember())))
                    .write(".join(', ')")
                    .dedent()
                    .closeBlock("end");
            return null;
        }

        @Override
        public Void mapShape(MapShape shape) {
            // Not supported in headers
            return null;
        }

        @Override
        public Void structureShape(StructureShape shape) {
            // Not supported in headers
            return null;
        }

        @Override
        public Void unionShape(UnionShape shape) {
            // Not supported in headers
            return null;
        }
    }

    private class HeaderListMemberSerializer extends ShapeVisitor.Default<Void> {

        private final MemberShape memberShape;

        HeaderListMemberSerializer(MemberShape memberShape) {
            this.memberShape = memberShape;
        }

        @Override
        protected Void getDefault(Shape shape) {
            writer.write(".map { |s| s.to_s }");
            return null;
        }

        @Override
        public Void stringShape(StringShape shape) {
            writer
                    .write(".map { |s| (s.include?('\"') || s.include?(\",\"))"
                            + " ? \"\\\"#{s.gsub('\"', '\\\"')}\\\"\" : s }");
            return null;
        }

        @Override
        public Void timestampShape(TimestampShape shape) {
            writer.write(".map { |s| $L }",
                    TimestampFormat.serializeTimestamp(
                            shape, memberShape, "s", TimestampFormatTrait.Format.DATE_TIME, true));
            return null;
        }
    }
}
