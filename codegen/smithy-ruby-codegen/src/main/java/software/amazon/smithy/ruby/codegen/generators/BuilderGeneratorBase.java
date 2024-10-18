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
import software.amazon.smithy.codegen.core.Symbol;
import software.amazon.smithy.codegen.core.SymbolProvider;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.knowledge.TopDownIndex;
import software.amazon.smithy.model.neighbor.Walker;
import software.amazon.smithy.model.shapes.BlobShape;
import software.amazon.smithy.model.shapes.BooleanShape;
import software.amazon.smithy.model.shapes.ByteShape;
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
import software.amazon.smithy.model.shapes.UnionShape;
import software.amazon.smithy.model.traits.EventHeaderTrait;
import software.amazon.smithy.model.traits.EventPayloadTrait;
import software.amazon.smithy.model.traits.MediaTypeTrait;
import software.amazon.smithy.model.traits.RequiresLengthTrait;
import software.amazon.smithy.model.traits.StreamingTrait;
import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.RubyCodeWriter;
import software.amazon.smithy.ruby.codegen.RubyImportContainer;
import software.amazon.smithy.ruby.codegen.RubySettings;
import software.amazon.smithy.ruby.codegen.util.Streaming;
import software.amazon.smithy.utils.SmithyUnstableApi;

/**
 * Base class for Builders which iterates shapes and builds skeleton classes.
 */
@SmithyUnstableApi
public abstract class BuilderGeneratorBase {

    private static final Logger LOGGER =
            Logger.getLogger(BuilderGeneratorBase.class.getName());

    /**
     * Generation context.
     */
    protected final GenerationContext context;
    /**
     * Ruby Settings.
     */
    protected final RubySettings settings;
    /**
     * Model to generate for.
     */
    protected final Model model;
    /**
     * Set of builders that have already been generated.
     */
    protected final Set<ShapeId> generatedBuilders;
    /**
     * CodeWriter to use for writing.
     */
    protected final RubyCodeWriter writer;
    /**
     * SymbolProvider scoped to this module.
     */
    protected final SymbolProvider symbolProvider;

    public BuilderGeneratorBase(GenerationContext context) {
        this.settings = context.settings();
        this.model = context.model();
        this.generatedBuilders = new HashSet<>();
        this.context = context;
        this.writer = new RubyCodeWriter(context.settings().getModule() + "::Builder");
        this.symbolProvider = context.symbolProvider();
    }

    /**
     * Called to render the build method for an operation.
     * The build method must take a request and input and serialize the input onto the request.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class Operation
     *   #### START code generated by this method
     *   def self.build(http_req, input:)
     *     http_req.http_method = 'POST'
     *     http_req.append_path('/Operation')
     *     data = {}
     *     data['timestamp'] = Hearth::TimeHelper.to_epoch_seconds(input.timestamp) unless input.timestamp.nil?
     *     http_req.body = StringIO.new(Hearth::JSON.dump(data))
     *   end
     *   #### END code generated by this method
     * end
     * }</pre>
     *
     * @param operation  the operation to generate for.
     * @param inputShape the operation's input.
     * @param isEventStream true when the operations input has an event stream.
     */
    protected abstract void renderOperationBuildMethod(OperationShape operation, Shape inputShape,
                                                       boolean isEventStream);

    /**
     * Called to render builders for Structure shapes.
     * The class skeleton is rendered outside of this method
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class SimpleStruct
     *   #### START code generated by this method
     *   def self.build(input)
     *     data = {}
     *     data[:value] = input.value unless input.value.nil?
     *     data
     *   end
     *   #### END code generated by this method
     * end
     * }</pre>
     *
     * @param shape shape to generate for
     */
    protected abstract void renderStructureBuildMethod(StructureShape shape);

    /**
     * Called to render builders for list shapes.
     * The class skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class StringList
     *   #### START code generated by this method
     *   def self.build(input)
     *     data = []
     *     input.each do |element|
     *       data << element
     *     end
     *     data
     *   end
     *   #### END code generated by this method
     * end
     * }</pre>
     *
     * @param shape shape to generate for
     */
    protected abstract void renderListBuildMethod(ListShape shape);

    /**
     * Called to render builders for Union member shapes.
     * The class  skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class MyUnion
     *   #### START code generated by this method
     *   def self.build(input)
     *     data = {}
     *     case input
     *     when Types::MyUnion::StructureValue
     *       data[:structure_value] = Builders::GreetingStruct.build(input)
     *     else
     *       raise ArgumentError,
     *       "Expected input to be one of the subclasses of Types::MyUnion"
     *     end
     *
     *     data
     *   end
     *   #### END code generated by this method
     * end
     * }</pre>
     *
     * @param shape union shape to generate for
     */
    protected abstract void renderUnionBuildMethod(UnionShape shape);

    /**
     * Called to render builders for map member shapes.
     * The class  skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class StringMap
     *   #### START code generated by this method
     *   def self.build(input)
     *     data = {}
     *     input.each do |key, value|
     *       data[key] = value
     *     end
     *     data
     *   end
     *   #### END code generated by this method
     * end
     * }</pre>
     *
     * @param shape shape to generate for
     */
    protected abstract void renderMapBuildMethod(MapShape shape);

    /**
     * Called to render payload serialization code for event streams with Structure payloads.
     * The rest of the build method is rendered outside of this method.  This method
     * must only generate code that sets the correct content-type and serializes the payload
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class ConfigurationEvent
     *   def self.build(input:)
     *     message = Hearth::EventStream::Message.new
     *     message.headers[':message-type'] = Hearth::EventStream::HeaderValue.new(value: 'event', type: 'string')
     *     message.headers[':event-type'] = Hearth::EventStream::HeaderValue.new(
     *       value: 'ConfigurationEvent', type: 'string')
     *     payload_input = input
     *     #### START code generated by this method
     *     message.headers[':content-type'] = Hearth::EventStream::HeaderValue.new(
     *       value: 'application/json', type: 'string')
     *     data = {}
     *     data['ChannelDefinitions'] = ChannelDefinitions.build(payload_input.channel_definitions)
     *       unless payload_input.channel_definitions.nil?
     *     data['PostCallAnalyticsSettings'] = PostCallAnalyticsSettings.build(
     *       payload_input.post_call_analytics_settings]) unless payload_input.post_call_analytics_settings].nil?
     *     message.payload = ::StringIO.new(Hearth::JSON.dump(data))
     *     #### END code generated by this method
     *
     *     message
     *   end
     * end
     * }</pre>
     *
     * @param eventPayload shape to generate for
     */
    protected abstract void renderEventPayloadStructureBuilder(StructureShape eventPayload);

    /**
     * Render the builder module.
     *
     * @param fileManifest files to generate to.
     */
    public void render(FileManifest fileManifest) {

        writer
                .preamble()
                .includeRequires()
                .openBlock("module $L", settings.getModule())
                .apiPrivate()
                .openBlock("module Builders")
                .call(() -> renderBuilders())
                .closeBlock("end")
                .closeBlock("end");

        String fileName = settings.getGemName() + "/lib/" + settings.getGemName() + "/builders.rb";
        fileManifest.writeFile(fileName, writer.toString());
        LOGGER.fine("Wrote builders to " + fileName);
    }

    /**
     * Called to render the build method for EventStream events.
     * The class skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * #### START code generated by this method
     * class SimpleEvent
     *   def self.build(input:)
     *     message = Hearth::EventStream::Message.new
     *     message.headers[':message-type'] = Hearth::EventStream::HeaderValue.new(value: 'event', type: 'string')
     *     message.headers[':event-type'] = Hearth::EventStream::HeaderValue.new(value: 'SimpleEvent', type: 'string')
     *     message
     *   end
     * end
     * #### END code generated by this method
     * }</pre>
     *
     * @param event event shape to generate for
     */
    protected void renderEventBuilder(StructureShape event) {
        Optional<MemberShape> payloadMember = event.members().stream()
                .filter(m -> m.hasTrait(EventPayloadTrait.class))
                .findFirst();

        writer
                .write("")
                .openBlock("class $L", symbolProvider.toSymbol(event).getName())
                .openBlock("def self.build(input:)")
                .write("message = Hearth::EventStream::Message.new")
                .write("message.headers[':message-type'] = "
                        + "Hearth::EventStream::HeaderValue.new(value: 'event', type: 'string')")
                .write("message.headers[':event-type'] = "
                                + "Hearth::EventStream::HeaderValue.new(value: '$L', type: 'string')",
                        event.getId().getName())
                .call(() -> {
                    renderBuildEventHeaders(event);
                })
                .call(() -> {
                    if (payloadMember.isPresent()) {
                        String valueGetter = "input." + symbolProvider.toMemberName(payloadMember.get());
                        model.expectShape(payloadMember.get().getTarget())
                                .accept(new EventPayloadSerializer(valueGetter));
                    } else {
                        String valueGetter = "input";
                        event.accept(new EventPayloadSerializer(valueGetter));
                    }
                })
                .write("message")
                .closeBlock("end")
                .closeBlock("end");
    }

    protected void renderBuildEventHeaders(StructureShape event) {
        event.members().stream().filter(m -> m.getTrait(EventHeaderTrait.class).isPresent()).forEach(m -> {
            String valueGetter = "input." + symbolProvider.toMemberName(m);
            writer.write("message.headers['$L'] = $L if $L",
                    m.getMemberName(),
                    model.expectShape(m.getTarget()).accept(new EventHeaderSerializer(valueGetter)),
                    valueGetter);
        });
    }

    /**
     * Render all builders.
     */
    protected void renderBuilders() {
        Comparator<Shape> comparator = Comparator.comparing(o -> o.getId().getName() + " " + o.getId());
        TreeSet<Shape> shapesToRender = new TreeSet<>(comparator);
        TreeSet<Shape> eventStreamEventsToRender = new TreeSet<>(comparator);
        TopDownIndex topDownIndex = TopDownIndex.of(model);
        Set<OperationShape> containedOperations = new TreeSet<>(
                topDownIndex.getContainedOperations(context.service()));
        containedOperations.stream()
                .forEach(o -> {
                    Shape inputShape = model.expectShape(o.getInputShape());
                    shapesToRender.add(o);
                    generatedBuilders.add(o.toShapeId());
                    generatedBuilders.add(inputShape.toShapeId());

                    Iterator<Shape> it = new Walker(model).iterateShapes(inputShape);
                    while (it.hasNext()) {
                        Shape s = it.next();
                        if (!StreamingTrait.isEventStream(s) && !generatedBuilders.contains(s.getId())) {
                            generatedBuilders.add(s.getId());
                            shapesToRender.add(s);
                        }
                    }

                    // add event stream events (members of the event stream union) if any
                    for (MemberShape memberShape : inputShape.members()) {
                        if (StreamingTrait.isEventStream(model, memberShape)) {
                            UnionShape eventStreamUnion = model.expectShape(memberShape.getTarget(), UnionShape.class);
                            for (MemberShape eventMember : eventStreamUnion.members()) {
                                Shape eventShape = model.expectShape(eventMember.getTarget());
                                eventStreamEventsToRender.add(eventShape);
                            }
                        }
                    }
                });

        // Render all shapes in alphabetical ordering
        shapesToRender
                .forEach(shape -> {
                    if (shape instanceof OperationShape operation) {
                        Shape inputShape = model.expectShape(operation.getInputShape());
                        renderBuildersForOperation(operation, inputShape);
                    } else {
                        shape.accept(new BuilderClassGenerator());
                    }
                });

        // Render event stream module with shapes in alphabetical order
        // EventStream event builders must be in a separate namespace since those shapes may be used in
        // non-event stream operations as well and require regular builders.
        if (!eventStreamEventsToRender.isEmpty()) {
            writer
                    .openBlock("module EventStream")
                    .call(() -> {
                        eventStreamEventsToRender.forEach(shape -> {
                            renderEventBuilder(shape.asStructureShape().get());
                        });
                    })
                    .closeBlock("end");
        }
    }

    /**
     * @param operation  operation to render for
     * @param inputShape the operation's inputShape.
     */
    protected void renderBuildersForOperation(OperationShape operation, Shape inputShape) {
        Symbol symbol = symbolProvider.toSymbol(operation);

        writer
                .write("")
                .openBlock("class $L", symbol.getName())
                .call(() -> {
                    renderOperationBuildMethod(operation, inputShape, Streaming.isEventStreaming(model, inputShape));
                })
                .closeBlock("end");
    }

    /**
     * @param inputShape inputShape from a streaming operation to render for.
     */
    protected void renderStreamingBodyBuilder(Shape inputShape) {
        MemberShape streamingMember = inputShape.members().stream()
                .filter((m) -> m.getMemberTrait(model, StreamingTrait.class).isPresent())
                .findFirst().get();

        Shape target = model.expectShape(streamingMember.getTarget());

        writer.write("http_req.body = input.$L", symbolProvider.toMemberName(streamingMember));
        if (!target.hasTrait(RequiresLengthTrait.class)) {
            writer.write("http_req.headers['Transfer-Encoding'] = 'chunked'");
        }

        if (target.hasTrait(MediaTypeTrait.class)) {
            writer.write("http_req.headers['Content-Type'] = '$L'",
                    target.expectTrait(MediaTypeTrait.class).getValue());
        } else {
            writer.write("http_req.headers['Content-Type'] = 'application/octet-stream'");
        }
    }


    protected class BuilderClassGenerator extends ShapeVisitor.Default<Void> {

        @Override
        protected Void getDefault(Shape shape) {
            return null;
        }

        @Override
        public Void structureShape(StructureShape shape) {
            Symbol symbol = symbolProvider.toSymbol(shape);
            writer
                    .write("")
                    .openBlock("class $L", symbol.getName())
                    .call(() -> renderStructureBuildMethod(shape))
                    .closeBlock("end");
            return null;
        }

        @Override
        public Void listShape(ListShape shape) {
            Symbol symbol = symbolProvider.toSymbol(shape);
            writer
                    .write("")
                    .openBlock("class $L", symbol.getName())
                    .call(() -> renderListBuildMethod(shape))
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void mapShape(MapShape shape) {
            Symbol symbol = symbolProvider.toSymbol(shape);
            writer
                    .write("")
                    .openBlock("class $L", symbol.getName())
                    .call(() -> renderMapBuildMethod(shape))
                    .closeBlock("end");

            return null;
        }


        @Override
        public Void unionShape(UnionShape shape) {
            Symbol symbol = symbolProvider.toSymbol(shape);
            writer
                    .write("")
                    .openBlock("class $L", symbol.getName())
                    .call(() -> renderUnionBuildMethod(shape))
                    .closeBlock("end");

            return null;
        }
    }

    protected static class EventHeaderSerializer extends ShapeVisitor.Default<String> {
        private final String valueGetter;

        public EventHeaderSerializer(String valueGetter) {
            this.valueGetter = valueGetter;
        }

        @Override
        protected String getDefault(Shape shape) {
            throw new SmithyBuildException("Unsupported EventHeader type: " + Shape.class);
        }

        @Override
        public String booleanShape(BooleanShape shape) {
            return "Hearth::EventStream::HeaderValue.new(value: %s, type: %s ? 'bool_true' : 'bool_false')".formatted(
                    valueGetter, valueGetter
            );
        }

        @Override
        public String byteShape(ByteShape shape) {
            return "Hearth::EventStream::HeaderValue.new(value: %s, type: 'byte')".formatted(
                    valueGetter
            );
        }

        @Override
        public String shortShape(ShortShape shape) {
            return "Hearth::EventStream::HeaderValue.new(value: %s, type: 'short')".formatted(
                    valueGetter
            );
        }

        @Override
        public String integerShape(IntegerShape shape) {
            return "Hearth::EventStream::HeaderValue.new(value: %s, type: 'integer')".formatted(
                    valueGetter
            );
        }

        @Override
        public String longShape(LongShape shape) {
            return "Hearth::EventStream::HeaderValue.new(value: %s, type: 'long')".formatted(
                    valueGetter
            );
        }

        @Override
        public String blobShape(BlobShape shape) {
            return "Hearth::EventStream::HeaderValue.new(value: %s, type: 'bytes')".formatted(
                    valueGetter
            );
        }

        @Override
        public String stringShape(StringShape shape) {
            return "Hearth::EventStream::HeaderValue.new(value: %s, type: 'string')".formatted(
                    valueGetter
            );
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
                    .write("payload_input = $L", valueGetter);

            renderEventPayloadStructureBuilder(shape);
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

