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

package software.amazon.smithy.ruby.codegen.generators;

import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.TreeSet;
import java.util.stream.Collectors;
import software.amazon.smithy.build.FileManifest;
import software.amazon.smithy.codegen.core.SymbolProvider;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.knowledge.TopDownIndex;
import software.amazon.smithy.model.neighbor.Walker;
import software.amazon.smithy.model.shapes.BigDecimalShape;
import software.amazon.smithy.model.shapes.BigIntegerShape;
import software.amazon.smithy.model.shapes.BlobShape;
import software.amazon.smithy.model.shapes.BooleanShape;
import software.amazon.smithy.model.shapes.ByteShape;
import software.amazon.smithy.model.shapes.DocumentShape;
import software.amazon.smithy.model.shapes.DoubleShape;
import software.amazon.smithy.model.shapes.FloatShape;
import software.amazon.smithy.model.shapes.IntegerShape;
import software.amazon.smithy.model.shapes.ListShape;
import software.amazon.smithy.model.shapes.LongShape;
import software.amazon.smithy.model.shapes.MapShape;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.SetShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.model.shapes.ShapeVisitor;
import software.amazon.smithy.model.shapes.ShortShape;
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
import software.amazon.smithy.ruby.codegen.RubyCodeWriter;
import software.amazon.smithy.ruby.codegen.RubyFormatter;
import software.amazon.smithy.ruby.codegen.RubySettings;
import software.amazon.smithy.ruby.codegen.RubySymbolProvider;

public abstract class HttpStubsGeneratorBase {
    protected final GenerationContext context;
    protected final RubySettings settings;
    protected final Model model;
    protected final Set<ShapeId> generatedStubs;
    protected final RubyCodeWriter writer;
    protected final SymbolProvider symbolProvider;


    public HttpStubsGeneratorBase(GenerationContext context) {
        this.settings = context.getRubySettings();
        this.model = context.getModel();
        this.generatedStubs = new HashSet<>();
        this.context = context;
        this.writer = new RubyCodeWriter();
        this.symbolProvider = new RubySymbolProvider(model, settings, "Stubs", true);
    }


    public void render(FileManifest fileManifest) {

        writer
                .writePreamble()
                .openBlock("module $L", settings.getModule())
                .openBlock("module Stubs")
                .call(() -> renderStubs())
                .closeBlock("end")
                .closeBlock("end");

        String fileName = settings.getGemName() + "/lib/" + settings.getGemName() + "/stubs.rb";
        fileManifest.writeFile(fileName, writer.toString());
    }

    private void renderStubs() {
        TopDownIndex topDownIndex = TopDownIndex.of(model);
        Set<OperationShape> containedOperations = new TreeSet<>(
                topDownIndex.getContainedOperations(context.getService()));
        containedOperations.stream()
                .sorted(Comparator.comparing((o) -> o.getId().getName()))
                .forEach(o -> {
                    Shape outputShape = model.expectShape(o.getOutput().orElseThrow(IllegalArgumentException::new));
                    renderStubsForOperation(o, outputShape);
                    generatedStubs.add(o.toShapeId());

                    Iterator<Shape> it = new Walker(model).iterateShapes(outputShape);
                    while (it.hasNext()) {
                        Shape s = it.next();
                        if (!generatedStubs.contains(s.getId())) {
                            generatedStubs.add(s.getId());
                            s.accept(new StubClassGenerator());
                        } else {
                            System.out.println("\tSkipping " + s.getId() + " because it has already been generated.");
                        }
                    }
                });
    }

    private void renderStubsForOperation(OperationShape operation, Shape outputShape) {
        System.out.println("Generating stubs for Operation: " + operation.getId());

        writer
                .write("")
                .write("# Operation Stubber for $L", operation.getId().getName())
                .openBlock("class $L", symbolProvider.toSymbol(operation).getName())
                .write("")
                .openBlock("def self.default(visited=[])")
                .call(() -> renderMemberDefaults(outputShape))
                .closeBlock("end")
                .write("")
                .openBlock("def self.stub(http_resp, stub:)")
                .call(() -> {
                    operation.getTrait(HttpTrait.class).ifPresent((httpTrait) -> {
                        writer.write("http_resp.status = $1L", httpTrait.getCode());
                    });
                })
                .call(() -> renderHeaderStubbers(operation, outputShape))
                .call(() -> renderPrefixHeadersStubbers(operation, outputShape))
                .call(() -> renderResponseCodeStubber(operation, outputShape))
                .call(() -> renderOperationBodyStubber(operation, outputShape))
                .closeBlock("end")
                .closeBlock("end");
    }

    // The Output shape is combined with the OperationStub
    // This generates the setting of the body (if any non-http input) as if it was the Stubber for the Output
    // Also marks the OutputShape as generated
    protected void renderOperationBodyStubber(OperationShape operation, Shape outputShape) {
        generatedStubs.add(outputShape.getId());

        //determine if there are any members of the input that need to be serialized to the body
        boolean serializeBody = outputShape.members().stream().anyMatch((m) -> !m.hasTrait(HttpLabelTrait.class)
                && !m.hasTrait(HttpQueryTrait.class) && !m.hasTrait(HttpHeaderTrait.class)
                && !m.hasTrait(HttpPrefixHeadersTrait.class)
                && !m.hasTrait(HttpQueryTrait.class) && !m.hasTrait(HttpQueryParamsTrait.class)
                && !m.hasTrait(HttpResponseCodeTrait.class));
        //determine if there is an httpPayload member
        List<MemberShape> httpPayloadMembers = outputShape.members()
                .stream()
                .filter((m) -> m.hasTrait(HttpPayloadTrait.class))
                .collect(Collectors.toList());
        if (httpPayloadMembers.size() == 0) {
            if (serializeBody) {
                renderNoPayloadBodyStub(operation, outputShape);
            }
        } else {
            MemberShape payloadMember = httpPayloadMembers.get(0);
            Shape target = model.expectShape(payloadMember.getTarget());
            renderPayloadBodyStub(operation, outputShape, payloadMember, target);
        }
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

    protected void renderMemberDefaults(Shape s) {
        writer.openBlock("{");
        s.members().forEach((member) -> {
            Shape target = model.expectShape(member.getTarget());
            System.out.println("\t\tMEMBER default FOR: " + member.getId() + " target type: " + target.getType());

            String symbolName = symbolProvider.toMemberName(member);
            String dataSetter = symbolName + ": ";
            target.accept(new MemberDefaults(dataSetter, ",", symbolName));
        });
        writer.closeBlock("}");
    }

    protected abstract void renderPayloadBodyStub(OperationShape operation, Shape outputShape,
                                                  MemberShape payloadMember, Shape target);

    protected abstract void renderNoPayloadBodyStub(OperationShape operation, Shape outputShape);

    protected abstract void renderUnionMemberStubbers(UnionShape shape);

    protected abstract void renderSetMemberStub(SetShape shape);

    protected abstract void renderMapMemberStub(MapShape shape);

    protected abstract void renderListMemberStub(ListShape shape);

    protected abstract void renderStructureMemberStubbers(StructureShape shape);

    private class StubClassGenerator extends ShapeVisitor.Default<Void> {

        @Override
        protected Void getDefault(Shape shape) {
            return null;
        }

        @Override
        public Void structureShape(StructureShape shape) {
            String name = symbolProvider.toSymbol(shape).getName();
            writer
                    .write("")
                    .write("# Structure Stubber for $L", shape.getId().getName())
                    .openBlock("class $L", name)
                    .write("")
                    .openBlock("def self.default(visited=[])")
                    .write("return nil if visited.include?('$L')", name)
                    .write("visited = visited + ['$L']", name)
                    .call(() -> renderMemberDefaults(shape))
                    .closeBlock("end")
                    .write("")
                    .openBlock("def self.stub(stub = {})")
                    .call(() -> renderStructureMemberStubbers(shape))
                    .write("data")
                    .closeBlock("end")
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void listShape(ListShape shape) {
            String name = symbolProvider.toSymbol(shape).getName();
            Shape memberTarget =
                    model.expectShape(shape.getMember().getTarget());
            writer
                    .write("")
                    .write("# List Stubber for $L", shape.getId().getName())
                    .openBlock("class $L", name)
                    .openBlock("def self.default(visited=[])")
                    .write("return nil if visited.include?('$L')", name)
                    .write("visited = visited + ['$L']", name)
                    .openBlock("[")
                    .call(() -> memberTarget.accept(new MemberDefaults("", "",
                            symbolProvider.toMemberName(shape.getMember()))))
                    .closeBlock("]")
                    .closeBlock("end")
                    .openBlock("def self.stub(stub = [])")
                    .write("data = []")
                    .openBlock("stub.each do |element|")
                    .call(() -> renderListMemberStub(shape))
                    .closeBlock("end")
                    .write("data")
                    .closeBlock("end")
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void setShape(SetShape shape) {
            String name = symbolProvider.toSymbol(shape).getName();
            MemberShape member = shape.getMember();
            Shape memberTarget =
                    model.expectShape(member.getTarget());
            writer
                    .write("")
                    .write("# Set Stubber for $L", shape.getId().getName())
                    .openBlock("class $L", name)
                    .openBlock("def self.default(visited=[])")
                    .write("return nil if visited.include?('$L')", name)
                    .write("visited = visited + ['$L']", name)
                    .openBlock("[")
                    .call(() -> memberTarget.accept(new MemberDefaults("", "",
                            symbolProvider.toMemberName(shape.getMember()))))
                    .closeBlock("]")
                    .closeBlock("end")
                    .write("")
                    .openBlock("def self.stub(stub = [])")
                    .write("data = Set.new")
                    .openBlock("stub.each do |element|")
                    .call(() -> renderSetMemberStub(shape))
                    .closeBlock("end")
                    .write("data.to_a")
                    .closeBlock("end")
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void mapShape(MapShape shape) {
            String name = symbolProvider.toSymbol(shape).getName();
            Shape valueTarget = model.expectShape(shape.getValue().getTarget());

            writer
                    .write("")
                    .write("# Map Stubber for $L", shape.getId().getName())
                    .openBlock("class $L", name)
                    .openBlock("def self.default(visited=[])")
                    .write("return nil if visited.include?('$L')", name)
                    .write("visited = visited + ['$L']", name)
                    .openBlock("{")
                    .call(() -> valueTarget
                            .accept(new MemberDefaults("test_key: ", "",
                                    symbolProvider.toMemberName(shape.getValue()))))
                    .closeBlock("}")
                    .closeBlock("end")
                    .write("")
                    .openBlock("def self.stub(stub = {})")
                    .write("data = {}")
                    .openBlock("stub.each do |key, value|")
                    .call(() -> renderMapMemberStub(shape))
                    .closeBlock("end")
                    .write("data")
                    .closeBlock("end")
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void unionShape(UnionShape shape) {
            String name = symbolProvider.toSymbol(shape).getName();
            writer
                    .write("")
                    .write("# Union Stubber for $L", shape.getId().getName())
                    .openBlock("class $L", name)
                    .openBlock("\ndef self.default(visited=[])")
                    .write("return nil if visited.include?('$L')", name)
                    .write("visited = visited + ['$L']", name)
                    .call(() -> {
                        writer.openBlock("{");
                        MemberShape defaultMember = shape.members().iterator().next();
                        Shape target = model.expectShape(defaultMember.getTarget());
                        String symbolName = RubyFormatter.toSnakeCase(symbolProvider.toMemberName(defaultMember));
                        String dataSetter = symbolName + ": ";
                        target.accept(new MemberDefaults(dataSetter, ",", symbolName));
                        writer.closeBlock("}");
                    })
                    .closeBlock("end")
                    .write("")
                    .openBlock("def self.stub(stub = {})")
                    .call(() -> renderUnionMemberStubbers(shape))
                    .write("data")
                    .closeBlock("end")
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void documentShape(DocumentShape shape) {
            System.out.println("\tRENDER stubber for Document: " + shape.getId());
            String name = symbolProvider.toSymbol(shape).getName();
            writer
                    .write("")
                    .write("# Document Type Stubber for $L", name)
                    .openBlock("class $L", name)
                    .openBlock("def self.default(visited=[])")
                    .write("return nil if visited.include?('$L')", name)
                    .write("visited = visited + ['$L']", name)
                    .write("{ '$L' => [0, 1, 2] }", name)
                    .closeBlock("end")
                    .write("")
                    .openBlock("def self.stub(stub = {})")
                    .write("stub")
                    .closeBlock("end")
                    .closeBlock("end");

            return null;
        }
    }

    private class MemberDefaults extends ShapeVisitor.Default<Void> {

        private final String eol;
        private final String dataSetter;
        private final String memberName;

        MemberDefaults(String dataSetter, String eol,
                       String memberName) {
            this.eol = eol;
            this.dataSetter = dataSetter;
            this.memberName = memberName;
        }

        @Override
        protected Void getDefault(Shape shape) {
            writer.write("$Lnil$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void blobShape(BlobShape blob) {
            writer.write("$L'$L'$L", dataSetter, memberName, eol);
            return null;
        }

        @Override
        public Void byteShape(ByteShape shape) {
            writer.write("$L1$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void shortShape(ShortShape shape) {
            writer.write("$L1$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void integerShape(IntegerShape shape) {
            writer.write("$L1$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void longShape(LongShape shape) {
            writer.write("$L1$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void floatShape(FloatShape shape) {
            writer.write("$L1.0$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void doubleShape(DoubleShape shape) {
            writer.write("$L1.0$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void bigIntegerShape(BigIntegerShape shape) {
            writer.write("$L1$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void bigDecimalShape(BigDecimalShape shape) {
            writer.write("$L1.0$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void stringShape(StringShape shape) {
            writer.write("$L'$L'$L", dataSetter, memberName, eol);
            return null;
        }

        @Override
        public Void timestampShape(TimestampShape shape) {
            writer.write("$LTime.now$L", dataSetter, eol);
            return null;
        }

        @Override
        public Void booleanShape(BooleanShape shape) {
            writer.write("$Lfalse$L", dataSetter, eol);
            return null;
        }

        /**
         * For complex shapes, simply delegate to their Stubber.
         */
        private void complexShapeDefaults(Shape shape) {
            writer.write("$LStubs::$L.default(visited)$L", dataSetter, symbolProvider.toSymbol(shape).getName(), eol);
        }

        @Override
        public Void listShape(ListShape shape) {
            complexShapeDefaults(shape);
            return null;
        }

        @Override
        public Void setShape(SetShape shape) {
            complexShapeDefaults(shape);
            return null;
        }

        @Override
        public Void mapShape(MapShape shape) {
            complexShapeDefaults(shape);
            return null;
        }

        @Override
        public Void structureShape(StructureShape shape) {
            complexShapeDefaults(shape);
            return null;
        }

        @Override
        public Void unionShape(UnionShape shape) {
            complexShapeDefaults(shape);
            return null;
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
            // header values are serialized using the http-date format by default
            Optional<TimestampFormatTrait> format = memberShape.getTrait(TimestampFormatTrait.class);
            if (!format.isPresent()) {
                format = shape.getTrait(TimestampFormatTrait.class);
            }
            if (format.isPresent()) {
                switch (format.get().getFormat()) {
                    case EPOCH_SECONDS:
                        writer.write("$1LSeahorse::TimeHelper.to_epoch_seconds($2L).to_i unless $2L.nil?", dataSetter,
                                inputGetter);
                        break;
                    case DATE_TIME:
                        writer.write("$1LSeahorse::TimeHelper.to_date_time($2L) unless $2L.nil?", dataSetter,
                                inputGetter);
                        break;
                    case HTTP_DATE:
                    default:
                        writer.write("$1LSeahorse::TimeHelper.to_http_date($2L) unless $2L.nil?", dataSetter,
                                inputGetter);
                        break;
                }
            } else {
                writer.write("$1LSeahorse::TimeHelper.to_http_date($2L) unless $2L.nil?", dataSetter, inputGetter);
            }
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
            // header values are serialized using the http-date format by default
            Optional<TimestampFormatTrait> format = memberShape.getTrait(TimestampFormatTrait.class);
            if (format.isPresent()) {
                switch (format.get().getFormat()) {
                    case EPOCH_SECONDS:
                        writer.write(".map { |s| Seahorse::TimeHelper.to_epoch_seconds(s) }");
                        break;
                    case DATE_TIME:
                        writer.write(".map { |s| Seahorse::TimeHelper.to_date_time(s) }");
                        break;
                    case HTTP_DATE:
                    default:
                        // TODO: Currently parsing of http_date in header lists is not supported
                        writer.write(".map { |s| Seahorse::TimeHelper.to_date_time(s) }");
                        break;
                }
            } else {
                // TODO: Currently parsing of http_date in header lists is not supported
                writer.write(".map { |s| Seahorse::TimeHelper.to_date_time(s) }");
            }
            return null;
        }
    }
}
