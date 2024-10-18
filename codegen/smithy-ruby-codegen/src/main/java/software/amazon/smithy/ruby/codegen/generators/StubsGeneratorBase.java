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

import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Optional;
import java.util.Set;
import java.util.TreeSet;
import java.util.logging.Logger;
import software.amazon.smithy.build.FileManifest;
import software.amazon.smithy.build.SmithyBuildException;
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
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.model.shapes.ShapeVisitor;
import software.amazon.smithy.model.shapes.ShortShape;
import software.amazon.smithy.model.shapes.StringShape;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.shapes.TimestampShape;
import software.amazon.smithy.model.shapes.UnionShape;
import software.amazon.smithy.model.traits.ErrorTrait;
import software.amazon.smithy.model.traits.EventHeaderTrait;
import software.amazon.smithy.model.traits.EventPayloadTrait;
import software.amazon.smithy.model.traits.StreamingTrait;
import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.RubyCodeWriter;
import software.amazon.smithy.ruby.codegen.RubyFormatter;
import software.amazon.smithy.ruby.codegen.RubyImportContainer;
import software.amazon.smithy.ruby.codegen.RubySettings;
import software.amazon.smithy.ruby.codegen.util.Streaming;

/**
 * Base class for Stubs which iterates shapes and builds skeleton classes.
 *
 * <p>
 * Protocols should extend this class to get common functionality -
 * generates the framework and non-protocol specific parts of
 * stubs.rb.
 */
public abstract class StubsGeneratorBase {

    private static final Logger LOGGER =
            Logger.getLogger(RestStubsGeneratorBase.class.getName());

    protected final GenerationContext context;
    protected final RubySettings settings;
    protected final Model model;
    protected final Set<ShapeId> generatedStubs;
    protected final RubyCodeWriter writer;
    protected final SymbolProvider symbolProvider;


    public StubsGeneratorBase(GenerationContext context) {
        this.settings = context.settings();
        this.model = context.model();
        this.generatedStubs = new HashSet<>();
        this.context = context;
        this.writer = new RubyCodeWriter(context.settings().getModule() + "::Stubs");
        this.symbolProvider = context.symbolProvider();
    }

    /**
     * Called to render the stub method for Union shapes.
     * The class  skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * #### START code generated by this method
     * def self.stub(stub = {})
     *   stub ||= {}
     *   data = {}
     *   data[:string_value] = stub.string_value unless stub.string_value.nil?
     *   data[:structure_value] = Stubs::GreetingStruct.stub(stub.structure_value) unless stub.structure_value.nil?
     *   data
     * end
     * #### END code generated by this method
     * }</pre>
     *
     * @param shape shape to generate for
     */
    protected abstract void renderUnionStubMethod(UnionShape shape);

    /**
     * Called to render the stub method for list shapes.
     * The class  skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * #### START code generated by this method
     * def self.stub(stub = [])
     *   data = []
     *   stub.each do |element|
     *     data << element
     *   end
     *   data
     * end
     *  #### END code generated by this method
     * }</pre>
     *
     * @param shape shape to generate for
     */
    protected abstract void renderListStubMethod(ListShape shape);

    /**
     * Called to render the stub method for map shapes.
     * The class  skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * #### START code generated by this method
     * def self.stub(stub = {})
     *   data = {}
     *   stub.each do |key, value|
     *     data[key] = value
     *   end
     *   data
     * end
     * #### END code generated by this method
     * }</pre>
     *
     * @param shape shape to generate for
     */
    protected abstract void renderMapStubMethod(MapShape shape);

    /**
     * Called to render the stub method for Structure shapes.
     * The class skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * #### START code generated by this method
     * def self.stub(stub = {})
     *   stub ||= {}
     *   data = {}
     *   data[:value] = stub.value unless stub.value.nil?
     *   data
     * end
     * #### END code generated by this method
     * }</pre>
     *
     * @param shape shape to generate for
     */
    protected abstract void renderStructureStubMethod(StructureShape shape);

    /**
     * Called to render the stub method for Operations.
     * The class skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * #### START code generated by this method
     * def self.stub(http_resp, stub:)
     *   data = {}
     *   http_resp.status = 200
     *   http_resp.headers['Content-Type'] = 'application/json'
     *   data['contents'] = Stubs::Contents.stub(stub.contents) unless stub.contents.nil?
     *   http_resp.body.write(Hearth::JSON.dump(data))
     * end
     * #### END code generated by this method
     * }</pre>
     *
     * @param operation   operation to render stub method for
     * @param outputShape output shape of the operation
     * @param isEventStream true when the operations input has an event  stream.
     */
    protected abstract void renderOperationStubMethod(
            OperationShape operation, Shape outputShape, boolean isEventStream);

    /**
     * Called to render the stub method for Errors.
     * The class skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * #### START code generated by this method
     * def self.stub(http_resp, stub:)
     *   data = {}
     *   http_resp.status = 400
     *   http_resp.headers['Content-Type'] = 'application/json'
     *   data['message'] = stub.message unless stub.message.nil?
     *   http_resp.body.write(Hearth::JSON.dump(data))
     * end
     * #### END code generated by this method
     * }</pre>
     *
     * @param errorShape error shape to render stub method for
     */
    protected abstract void renderErrorStubMethod(Shape errorShape);

    /**
     * Called to render payload stub serialization code for event streams with Structure payloads.
     * The rest of the stub method is rendered outside of this method.  This method
     * must only generate code that sets the correct content-type and serializes the payload
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class NestedEvent
     *   def self.stub(stub)
     *     message = Hearth::EventStream::Message.new
     *     message.headers[':message-type'] = Hearth::EventStream::HeaderValue.new(value: 'event', type: 'string')
     *     message.headers[':event-type'] = Hearth::EventStream::HeaderValue.new(value: 'NestedEvent', type: 'string')
     *     #### START code generated by this method
     *     payload_stub = stub
     *     data = {}
     *     data['nested'] = NestedStructure.stub(payload_stub.nested) unless payload_stub.nested.nil?
     *     data['message'] = payload_stub.message unless payload_stub.message.nil?
     *     message.payload = ::StringIO.new(Hearth::JSON.dump(data))
     *     #### END code generated by this method
     *     message
     *   end
     * end
     * }</pre>
     *
     * @param eventPayload shape to generate for
     */
    protected abstract void renderEventPayloadStructureStub(StructureShape eventPayload);


    public void render(FileManifest fileManifest) {
        writer
                .preamble()
                .includeRequires()
                .openBlock("module $L", settings.getModule())
                .apiPrivate()
                .openBlock("module Stubs")
                .call(() -> renderStubs())
                .closeBlock("end")
                .closeBlock("end");

        String fileName = settings.getGemName() + "/lib/" + settings.getGemName() + "/stubs.rb";
        fileManifest.writeFile(fileName, writer.toString());

        LOGGER.fine("Wrote stubs to " + fileName);
    }

    private void renderStubs() {
        Comparator<Shape> comparator = Comparator.comparing(o -> o.getId().getName() + " " + o.getId());
        TreeSet<Shape> shapesToRender = new TreeSet<>(comparator);
        TreeSet<Shape> eventStreamEventsToRender = new TreeSet<>(comparator);
        TopDownIndex topDownIndex = TopDownIndex.of(model);
        Set<OperationShape> containedOperations = new TreeSet<>(
                topDownIndex.getContainedOperations(context.service()));
        containedOperations.stream()
                .sorted(Comparator.comparing((o) -> o.getId().getName()))
                .forEach(o -> {
                    Shape outputShape = model.expectShape(o.getOutputShape());
                    shapesToRender.add(o);
                    generatedStubs.add(o.toShapeId());
                    generatedStubs.add(outputShape.toShapeId());
                    Iterator<Shape> it = new Walker(model).iterateShapes(outputShape);
                    while (it.hasNext()) {
                        Shape s = it.next();
                        if (!StreamingTrait.isEventStream(s) && !generatedStubs.contains(s.getId())) {
                            generatedStubs.add(s.getId());
                            shapesToRender.add(s);
                        }
                    }

                    for (ShapeId errorShapeId : o.getErrors()) {
                        Iterator<Shape> errIt = new Walker(model).iterateShapes(model.expectShape(errorShapeId));
                        while (errIt.hasNext()) {
                            Shape s = errIt.next();
                            if (!generatedStubs.contains(s.getId())) {
                                generatedStubs.add(s.getId());
                                shapesToRender.add(s);
                            }
                        }
                    }

                    if (Streaming.isEventStreaming(model, outputShape)) {
                        for (MemberShape memberShape : outputShape.members()) {
                            if (StreamingTrait.isEventStream(model, memberShape)) {
                                UnionShape eventStreamUnion = model.expectShape(
                                        memberShape.getTarget(), UnionShape.class);
                                for (MemberShape eventMember : eventStreamUnion.members()) {
                                    eventStreamEventsToRender.add(model.expectShape(eventMember.getTarget()));
                                }
                            }
                        }
                    }
                });

        shapesToRender.forEach(shape -> {
            if (shape instanceof OperationShape operation) {
                Shape outputShape = model.expectShape(operation.getOutputShape());
                renderStubsForOperation(operation, outputShape);
            } else if (shape.hasTrait(ErrorTrait.class)) {
                renderErrorStub(shape);
            } else {
                shape.accept(new StubClassGenerator());
            }
        });

        // Render event stream module with shapes in alphabetical order
        // EventStream event stubbers must be in a separate namespace since those shapes may be used in
        // non-event stream operations as well.
        if (!eventStreamEventsToRender.isEmpty()) {
            writer
                    .write("")
                    .openBlock("module EventStream")
                    .call(() -> {
                        // Render all shapes in alphabetical ordering
                        eventStreamEventsToRender
                                .forEach(shape -> {
                                    // Event stream event members MUST target only StructureShapes
                                    writer
                                            .write("")
                                            .openBlock("class $L", symbolProvider.toSymbol(shape).getName())
                                            .call(() -> renderEventStubMethod(shape.asStructureShape().get()))
                                            .closeBlock("end");
                                });
                    })
                    .closeBlock("end");
        }
    }

    protected void renderEventStubMethod(StructureShape event) {
        Optional<MemberShape> payloadMember = event.members().stream()
                .filter(m -> m.hasTrait(EventPayloadTrait.class))
                .findFirst();

        writer
                .openBlock("def self.stub(event_type, stub)")
                .write("message = Hearth::EventStream::Message.new")
                .write("message.headers[':message-type'] = "
                       + "Hearth::EventStream::HeaderValue.new(value: 'event', type: 'string')")
                .write("message.headers[':event-type'] = "
                       + "Hearth::EventStream::HeaderValue.new(value: event_type, type: 'string')")
                .call(() -> {
                    renderStubEventHeaders(event);
                })
                .call(() -> {
                    if (payloadMember.isPresent()) {
                        String valueGetter = "stub." + symbolProvider.toMemberName(payloadMember.get());
                        model.expectShape(payloadMember.get().getTarget())
                                .accept(new EventPayloadSerializer(valueGetter));
                    } else {
                        String valueGetter = "stub";
                        event.accept(new EventPayloadSerializer(valueGetter));
                    }
                })
                .write("message")
                .closeBlock("end");
    }

    private void renderStubEventHeaders(StructureShape event) {
        event.members().stream().filter(m -> m.getTrait(EventHeaderTrait.class).isPresent()).forEach(m -> {
            String valueGetter = "stub." + symbolProvider.toMemberName(m);
            writer.write("message.headers['$L'] = $L if $L",
                    m.getMemberName(),
                    model.expectShape(m.getTarget()).accept(
                            new BuilderGeneratorBase.EventHeaderSerializer(valueGetter)),
                    valueGetter);
        });
    }

    protected void renderInitialResponseEventStubMethod(StructureShape structureShape) {
    }

    // The Output shape is combined with the OperationStub
    // This generates the setting of the body (if any non-http input) as if it was the Stubber for the Output
    private void renderStubsForOperation(OperationShape operation, Shape outputShape) {
        generatedStubs.add(outputShape.getId());
        String outputShapeName = symbolProvider.toSymbol(outputShape).getName();
        boolean isEventStream = Streaming.isEventStreaming(model, outputShape);

        writer
                .write("")
                .openBlock("class $L", symbolProvider.toSymbol(operation).getName())
                .call(() -> renderBuildMethod(outputShapeName))
                .write("")
                .call(() -> renderValidateMethod(outputShapeName))
                .write("")
                .call(() -> renderDefaultMethod(outputShape))
                .write("")
                .call(() -> renderOperationStubMethod(operation, outputShape, isEventStream))
                .call(() -> {
                    if (isEventStream) {
                        UnionShape eventStreamUnion = model.expectShape(
                                Streaming.getEventStreamMember(model, outputShape).get().getTarget(),
                                UnionShape.class);
                        renderDefaultEventMethod(eventStreamUnion);
                        writer.write("");
                        renderValidateEventMethod(eventStreamUnion);
                        writer.write("");
                        renderStubEventMethod(eventStreamUnion);
                    }
                })
                .closeBlock("end");
    }

    private void renderStubEventMethod(UnionShape eventStreamUnion) {
        writer
                .openBlock("def self.stub_event(stub)")
                .write("case stub")
                .call(() -> {
                    for (MemberShape memberShape : eventStreamUnion.members()) {
                        Shape target = model.expectShape(memberShape.getTarget());
                        writer
                                .write("when $T", symbolProvider.toSymbol(target))
                                .indent()
                                .write("EventStream::$L.stub('$L', stub)",
                                        symbolProvider.toSymbol(target).getName(),
                                        symbolProvider.toMemberName(memberShape))
                                .dedent();
                    }
                })
                .write("end") // end of case block, no dedent
                .closeBlock("end");
    }

    private void renderDefaultEventMethod(UnionShape eventStreamUnion) {
        String name = symbolProvider.toSymbol(eventStreamUnion).getName();
        writer
                .write("")
                .openBlock("def self.default_event(visited = [])")
                .write("return nil if visited.include?('$L')", name)
                .write("visited = visited + ['$L']", name)
                .call(() -> {
                    MemberShape defaultMember = eventStreamUnion.members().iterator().next();
                    Shape target = model.expectShape(defaultMember.getTarget());
                    String className = symbolProvider.toSymbol(target).getName();
                    writer.openBlock("Params::$L.build(", className);
                    String symbolName = RubyFormatter.toSnakeCase(symbolProvider.toMemberName(defaultMember));
                    target.accept(new MemberDefaults("", ",", symbolName));
                    writer.write("context: 'default_event'");
                    writer.closeBlock(")");
                })
                .closeBlock("end");
    }

    private void renderValidateEventMethod(UnionShape eventStreamUnion) {
        writer
                .openBlock("def self.validate_event!(event, context:)")
                .write("case event")
                .call(() -> {
                    for (MemberShape memberShape : eventStreamUnion.members()) {
                        Shape target = model.expectShape(memberShape.getTarget());
                        writer
                                .write("when $T", symbolProvider.toSymbol(memberShape))
                                .indent()
                                .write("Validators::$L.validate!(event, context: context)",
                                        symbolProvider.toSymbol(target).getName())
                                .dedent();
                    }
                })
                .write("end") // end of case block, no dedent
                .closeBlock("end");
    }

    private void renderErrorStub(Shape errorShape) {
        String errorShapeName = symbolProvider.toSymbol(errorShape).getName();

        writer
                .write("")
                .openBlock("class $L", errorShapeName)
                .call(() -> renderBuildMethod(errorShapeName))
                .write("")
                .call(() -> renderValidateMethod(errorShapeName))
                .write("")
                .call(() -> renderDefaultMethod(errorShape))
                .write("")
                .call(() -> renderErrorStubMethod(errorShape))
                .closeBlock("end");
    }

    private void renderBuildMethod(String className) {
        writer
                .openBlock("def self.build(params, context:)")
                .write("Params::$L.build(params, context: context)", className)
                .closeBlock("end");
    }

    private void renderValidateMethod(String className) {
        writer
                .openBlock("def self.validate!(output, context:)")
                .write("Validators::$L.validate!(output, context: context)", className)
                .closeBlock("end");
    }

    private void renderDefaultMethod(Shape shape) {
        writer
                .openBlock("def self.default(visited = [])")
                .call(() -> renderMemberDefaults(shape))
                .closeBlock("end");
    }

    protected void renderMemberDefaults(Shape s) {
        writer.openBlock("{");
        s.members().forEach((member) -> {
            if (!StreamingTrait.isEventStream(model, member)) {
                Shape target = model.expectShape(member.getTarget());

                String symbolName = symbolProvider.toMemberName(member);
                String dataSetter = symbolName + ": ";
                target.accept(new MemberDefaults(dataSetter, ",", symbolName));
            }
        });
        writer.closeBlock("}");
    }

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
                    .openBlock("class $L", name)
                    .openBlock("def self.default(visited = [])")
                    .write("return nil if visited.include?('$L')", name)
                    .write("visited = visited + ['$L']", name)
                    .call(() -> renderMemberDefaults(shape))
                    .closeBlock("end")
                    .write("")
                    .call(() -> renderStructureStubMethod(shape))
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
                    .openBlock("class $L", name)
                    .openBlock("def self.default(visited = [])")
                    .write("return nil if visited.include?('$L')", name)
                    .write("visited = visited + ['$L']", name)
                    .openBlock("[")
                    .call(() -> memberTarget.accept(new MemberDefaults("", "",
                            symbolProvider.toMemberName(shape.getMember()))))
                    .closeBlock("]")
                    .closeBlock("end")
                    .write("")
                    .call(() -> renderListStubMethod(shape))
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void mapShape(MapShape shape) {
            String name = symbolProvider.toSymbol(shape).getName();
            Shape valueTarget = model.expectShape(shape.getValue().getTarget());
            String symbolName = symbolProvider.toMemberName(shape.getKey());
            // String dataSetter = symbolName + ": ";
            String dataSetter = "'" + symbolName + "' => ";

            writer
                    .write("")
                    .openBlock("class $L", name)
                    .openBlock("def self.default(visited = [])")
                    .write("return nil if visited.include?('$L')", name)
                    .write("visited = visited + ['$L']", name)
                    .openBlock("{")
                    .call(() -> valueTarget
                            .accept(new MemberDefaults(dataSetter, "",
                                    symbolProvider.toMemberName(shape.getValue()))))
                    .closeBlock("}")
                    .closeBlock("end")
                    .write("")
                    .call(() -> renderMapStubMethod(shape))
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void unionShape(UnionShape shape) {
            String name = symbolProvider.toSymbol(shape).getName();
            writer
                    .write("")
                    .openBlock("class $L", name)
                    .openBlock("def self.default(visited = [])")
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
                    .call(() -> renderUnionStubMethod(shape))
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void documentShape(DocumentShape shape) {
            String name = symbolProvider.toSymbol(shape).getName();
            writer
                    .write("")
                    .openBlock("class $L", name)
                    .openBlock("def self.default(visited = [])")
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
            writer.write("$L$L.default(visited)$L", dataSetter, symbolProvider.toSymbol(shape).getName(), eol);
        }

        @Override
        public Void listShape(ListShape shape) {
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

    protected class EventPayloadSerializer extends ShapeVisitor.Default<Void> {

        private final String valueGetter;

        public EventPayloadSerializer(String valueGetter) {
            this.valueGetter = valueGetter;
        }

        @Override
        protected Void getDefault(Shape shape) {
            throw new SmithyBuildException("Unsupported type for EventPayload: " + shape.getClass());
        }

        @Override
        public Void structureShape(StructureShape shape) {
            writer
                    .write("payload_stub = $L", valueGetter);

            renderEventPayloadStructureStub(shape);
            return null;
        }

        @Override
        public Void blobShape(BlobShape shape) {
            writer
                    .write("message.headers[':content-type'] = "
                           + "Hearth::EventStream::HeaderValue.new("
                           + "value: 'application/octet-stream', type: 'string')")
                    .write("message.payload = $T.new($L)",
                            RubyImportContainer.STRING_IO, valueGetter);
            return null;
        }

        @Override
        public Void stringShape(StringShape shape) {
            writer
                    .write("message.headers[':content-type'] = "
                           + "Hearth::EventStream::HeaderValue.new("
                           + "value: 'application/text', type: 'string')")
                    .write("message.payload = $T.new($L)",
                            RubyImportContainer.STRING_IO, valueGetter);
            return null;
        }

    }
}
