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
import java.util.Set;
import java.util.TreeSet;
import java.util.logging.Logger;
import software.amazon.smithy.build.FileManifest;
import software.amazon.smithy.codegen.core.Symbol;
import software.amazon.smithy.codegen.core.SymbolProvider;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.knowledge.TopDownIndex;
import software.amazon.smithy.model.neighbor.Walker;
import software.amazon.smithy.model.shapes.ListShape;
import software.amazon.smithy.model.shapes.MapShape;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.SetShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.model.shapes.ShapeVisitor;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.shapes.UnionShape;
import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.RubyCodeWriter;
import software.amazon.smithy.ruby.codegen.RubySettings;
import software.amazon.smithy.ruby.codegen.RubySymbolProvider;
import software.amazon.smithy.utils.SmithyUnstableApi;

/**
 * Base class for Builders which iterates shapes and builds skeleton classes.
 */
@SmithyUnstableApi
public abstract class BuilderGeneratorBase {

    private static final Logger LOGGER =
            Logger.getLogger(BuilderGeneratorBase.class.getName());

    protected final GenerationContext context;
    protected final RubySettings settings;
    protected final Model model;
    protected final Set<ShapeId> generatedBuilders;
    protected final RubyCodeWriter writer;
    protected final SymbolProvider symbolProvider;

    public BuilderGeneratorBase(GenerationContext context) {
        this.settings = context.getRubySettings();
        this.model = context.getModel();
        this.generatedBuilders = new HashSet<>();
        this.context = context;
        this.writer = new RubyCodeWriter();
        this.symbolProvider = new RubySymbolProvider(model, settings, "Builder", true);
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
     *     data['timestamp'] = Hearth::TimeHelper.to_epoch_seconds(input[:timestamp]) unless input[:timestamp].nil?
     *     http_req.body = StringIO.new(Hearth::JSON.dump(data))
     *   end
     *   #### END code generated by this method
     * end
     * }</pre>
     *
     * @param operation the operation to generate for.
     * @param inputShape the operation's input.
     */
    protected abstract void renderOperationBuildMethod(OperationShape operation, Shape inputShape);

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
     *     data[:value] = input[:value] unless input[:value].nil?
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
     * Called to render builders for set member shapes.
     * The class skeleton is rendered outside of this method.
     *
     * <p>The following example shows the generated skeleton and an example of what
     * this method is expected to render.</p>
     * <pre>{@code
     * class StringSet
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
    protected abstract void renderSetBuildMethod(SetShape shape);

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

    public void render(FileManifest fileManifest) {

        writer
                .writePreamble()
                .write("require 'base64'\n")
                .openBlock("module $L", settings.getModule())
                .openBlock("module Builders")
                .call(() -> renderBuilders())
                .closeBlock("end")
                .closeBlock("end");

        String fileName = settings.getGemName() + "/lib/" + settings.getGemName() + "/builders.rb";
        fileManifest.writeFile(fileName, writer.toString());
        LOGGER.fine("Wrote builders to " + fileName);
    }

    protected void renderBuilders() {
        TopDownIndex topDownIndex = TopDownIndex.of(model);
        Set<OperationShape> containedOperations = new TreeSet<>(
                topDownIndex.getContainedOperations(context.getService()));
        containedOperations.stream()
                .sorted(Comparator.comparing((o) -> o.getId().getName()))
                .forEach(o -> {
                    Shape inputShape = model.expectShape(o.getInputShape());
                    renderBuildersForOperation(o, inputShape);
                    generatedBuilders.add(o.toShapeId());
                    generatedBuilders.add(inputShape.toShapeId());

                    Iterator<Shape> it = new Walker(model).iterateShapes(inputShape);
                    while (it.hasNext()) {
                        Shape s = it.next();
                        if (!generatedBuilders.contains(s.getId())) {
                            generatedBuilders.add(s.getId());
                            s.accept(new BuilderClassGenerator());
                        }
                    }
                });
    }

    protected void renderBuildersForOperation(OperationShape operation, Shape inputShape) {
        Symbol symbol = symbolProvider.toSymbol(operation);

        writer
                .write("")
                .write("# Operation Builder for $L", operation.getId().getName())
                .openBlock("class $L", symbol.getName())
                .call(() -> renderOperationBuildMethod(operation, inputShape))
                .closeBlock("end");

        LOGGER.finer("Generated operation builder for: " + operation.getId().getName());
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
                    .write("# Structure Builder for $L", shape.getId().getName())
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
                    .write("# List Builder for $L", shape.getId().getName())
                    .openBlock("class $L", symbol.getName())
                    .call(() -> renderListBuildMethod(shape))
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void setShape(SetShape shape) {
            Symbol symbol = symbolProvider.toSymbol(shape);
            writer
                    .write("")
                    .write("# Set Builder for $L", shape.getId().getName())
                    .openBlock("\nclass $L", symbol.getName())
                    .call(() -> renderSetBuildMethod(shape))
                    .closeBlock("end");

            return null;
        }

        @Override
        public Void mapShape(MapShape shape) {
            Symbol symbol = symbolProvider.toSymbol(shape);
            writer
                    .write("")
                    .write("# Map Builder for $L", shape.getId().getName())
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
                    .write("# Structure Builder for $L", shape.getId().getName())
                    .openBlock("class $L", symbol.getName())
                    .call(() -> renderUnionBuildMethod(shape))
                    .closeBlock("end");

            return null;
        }
    }
}

