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

package software.amazon.smithy.ruby.codegen.fakeprotocol.generators;

import java.util.Comparator;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;
import java.util.TreeSet;
import software.amazon.smithy.build.FileManifest;
import software.amazon.smithy.model.Model;
import software.amazon.smithy.model.knowledge.TopDownIndex;
import software.amazon.smithy.model.neighbor.Walker;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeId;
import software.amazon.smithy.model.shapes.ShapeVisitor;
import software.amazon.smithy.model.traits.ErrorTrait;
import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.RubyCodeWriter;
import software.amazon.smithy.ruby.codegen.RubySettings;

public class ParserGenerator extends ShapeVisitor.Default<Void> {
    private final GenerationContext context;
    private final RubySettings settings;
    private final Model model;
    private final Set<ShapeId> generatedParsers;
    private final Set<String> generatedErrorParsers;

    private final RubyCodeWriter writer;

    public ParserGenerator(GenerationContext context) {
        this.context = context;
        this.settings = context.getRubySettings();
        this.model = context.getModel();
        this.generatedParsers = new HashSet<>();
        this.generatedErrorParsers = new HashSet<>();
        this.writer = new RubyCodeWriter();
    }

    public void render(FileManifest fileManifest) {
        writer
                .write("require 'base64'\n")
                .openBlock("module $L", settings.getModule())
                .openBlock("module Parsers")
                .call(() -> renderParsers())
                .closeBlock("end")
                .closeBlock("end");

        String fileName = settings.getGemName() + "/lib/" + settings.getGemName() + "/parsers.rb";
        fileManifest.writeFile(fileName, writer.toString());
    }

    private void renderParsers() {
        TopDownIndex topDownIndex = TopDownIndex.of(model);
        Set<OperationShape> containedOperations = new TreeSet<>(
                topDownIndex.getContainedOperations(context.getService()));
        containedOperations.stream()
                .sorted(Comparator.comparing((o) -> o.getId().getName()))
                .forEach(o -> renderParsersForOperation(o));
    }

    private void renderParsersForOperation(OperationShape operation) {
        // Operations MUST have an Output type, even if it is empty
        if (!operation.getOutput().isPresent()) {
            throw new RuntimeException("Missing Output Shape for: " + operation.getId());
        }

        ShapeId outputShapeId = operation.getOutput().get();
        Shape outputShape = model.expectShape(outputShapeId);

        writer
                .write("\n# Operation Parser for $L", operation.getId().getName())
                .openBlock("class $L", operation.getId().getName())
                .openBlock("def self.parse(http_resp)")
                .write("data = Types::$L.new", outputShapeId.getName())
                .write("data")
                .closeBlock("end")
                .closeBlock("end");

        generatedParsers.add(operation.toShapeId());
        generatedParsers.add(outputShapeId);

        Iterator<Shape> it = new Walker(model).iterateShapes(outputShape);
        while (it.hasNext()) {
            Shape s = it.next();
            if (!generatedParsers.contains(s.getId())) {
                generatedParsers.add(s.getId());
                s.accept(this);
            } else {
                System.out.println("\tSkipping " + s.getId() + " because it has already been generated.");
            }
        }

        for (ShapeId errorShapeId : operation.getErrors()) {
            Iterator<Shape> errIt = new Walker(model).iterateShapes(model.expectShape(errorShapeId));
            while (errIt.hasNext()) {
                Shape s = errIt.next();
                if (!generatedParsers.contains(s.getId())) {
                    generatedParsers.add(s.getId());
                    if (s.hasTrait(ErrorTrait.class)) {
                        writer
                                .write("\n# Error Parser for $L", s.getId().getName())
                                .openBlock("class $L", s.getId().getName())
                                .openBlock("def self.parse(http_resp)")
                                .write("data = Types::$L.new", s.getId().getName())
                                .write("data")
                                .closeBlock("end")
                                .closeBlock("end");
                    } else {
                        s.accept(this);
                    }
                }
            }
        }
    }

    @Override
    protected Void getDefault(Shape shape) {
        System.out.println("\tDefault VISIT for: " + shape.getId() + "\t" + shape.getClass().getSimpleName());
        return null;
    }
}

