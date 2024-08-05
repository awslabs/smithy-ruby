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

package software.amazon.smithy.ruby.codegen.protocol.rpcv2cbor.generators;


import java.util.stream.Stream;
import software.amazon.smithy.model.shapes.ListShape;
import software.amazon.smithy.model.shapes.MapShape;
import software.amazon.smithy.model.shapes.MemberShape;
import software.amazon.smithy.model.shapes.OperationShape;
import software.amazon.smithy.model.shapes.Shape;
import software.amazon.smithy.model.shapes.ShapeVisitor;
import software.amazon.smithy.model.shapes.StructureShape;
import software.amazon.smithy.model.shapes.UnionShape;
import software.amazon.smithy.model.traits.EventHeaderTrait;
import software.amazon.smithy.model.traits.SparseTrait;
import software.amazon.smithy.model.traits.StreamingTrait;
import software.amazon.smithy.ruby.codegen.GenerationContext;
import software.amazon.smithy.ruby.codegen.Hearth;
import software.amazon.smithy.ruby.codegen.generators.ParserGeneratorBase;
import software.amazon.smithy.ruby.codegen.traits.NoSerializeTrait;

public class ParserGenerator extends ParserGeneratorBase {

    public ParserGenerator(GenerationContext context) {
        super(context);
    }

    private void renderMemberParsers(Shape s) {
        //remove members w/ http traits or marked NoSerialize
        Stream<MemberShape> serializeMembers = s.members().stream()
                .filter(NoSerializeTrait.excludeNoSerializeMembers())
                .filter(m -> !StreamingTrait.isEventStream(model, m))
                .filter(m -> !m.hasTrait(EventHeaderTrait.class));

        serializeMembers.forEach((member) -> {
            Shape target = model.expectShape(member.getTarget());
            String dataName = symbolProvider.toMemberName(member);
            String dataSetter = "data." + dataName + " = ";
            String jsonName = member.getMemberName();

            String valueGetter = "map['" + jsonName + "']";
            target.accept(new MemberDeserializer(member, dataSetter, valueGetter, false));
        });
    }

    @Override
    protected void renderUnionParseMethod(UnionShape s) {
        writer
                .openBlock("def self.parse(map)")
                .write("return nil if map.nil?\n")
                .write("map.delete('__type')")
                .write("key, value = map.compact.flatten")
                .write("case key")
                .call(() -> {
                    s.members().forEach((member) -> {
                        writer
                                .write("when '$L'", unionMemberDataName(s, member))
                                .indent()
                                .call(() -> {
                                    renderUnionMemberParser(s, member);
                                })
                                .write("$T.new(value) if value", context.symbolProvider().toSymbol(member))
                                .dedent();
                    });
                })
                .openBlock("else")
                .write("$T::Unknown.new(name: key, value: value)", context.symbolProvider().toSymbol(s))
                .closeBlock("end") // end of case
                .closeBlock("end");
    }

    private String unionMemberDataName(UnionShape s, MemberShape member) {
        return member.getMemberName();
    }

    private void renderUnionMemberParser(UnionShape s, MemberShape member) {
        Shape target = model.expectShape(member.getTarget());
        target.accept(new MemberDeserializer(member, "value = ",
                "value", false));
    }

    @Override
    protected void renderMapParseMethod(MapShape s) {
        writer
                .openBlock("def self.parse(map)")
                .write("data = {}")
                .openBlock("map.map do |key, value|")
                .call(() -> {
                    Shape valueTarget = model.expectShape(s.getValue().getTarget());
                    valueTarget
                            .accept(new MemberDeserializer(s.getValue(),
                                    "data[key] = ", "value",
                                    !s.hasTrait(SparseTrait.class)));
                })
                .closeBlock("end")
                .write("data")
                .closeBlock("end");
    }

    @Override
    protected void renderListParseMethod(ListShape s) {
        writer
                .openBlock("def self.parse(list)")
                .openBlock("list.map do |value|")
                .call(() -> {
                    Shape memberTarget =
                            model.expectShape(s.getMember().getTarget());
                    memberTarget
                            .accept(new MemberDeserializer(s.getMember(), "", "value", !s.hasTrait(SparseTrait.class)));
                })
                .closeBlock("end")
                .closeBlock("end");
    }

    @Override
    protected void renderStructureParseMethod(StructureShape s) {
        writer
                .openBlock("def self.parse(map)")
                .write("data = $T.new", context.symbolProvider().toSymbol(s))
                .call(() -> renderMemberParsers(s))
                .write("return data")
                .closeBlock("end");
    }

    @Override
    protected void renderOperationParseMethod(OperationShape operation, Shape outputShape) {
        writer
                .openBlock("def self.parse(http_resp)")
                .write("data = $T.new", context.symbolProvider().toSymbol(outputShape))
                .write("body = http_resp.body.read")
                .write("return data if body.empty?")
                .write("map = $T.decode(body)", Hearth.CBOR)
                 .call(() -> renderMemberParsers(outputShape))
                .write("data")
                .closeBlock("end");
    }

    @Override
    protected void renderErrorParseMethod(Shape shape) {
        writer
                .openBlock("def self.parse(http_resp)")
                .write("data = $T.new", context.symbolProvider().toSymbol(shape))
                .write("body = http_resp.body.read")
                .write("return data if body.empty?")
                .write("map = $T.decode(body)", Hearth.CBOR);
        renderMemberParsers(shape);
        writer
                .write("data")
                .closeBlock("end");
    }

    @Override
    protected void renderEventImplicitStructurePayloadParser(StructureShape event) {
        writer.write("map = $T.decode(payload)", Hearth.CBOR);
        renderMemberParsers(event);
    }

    @Override
    protected void renderEventExplicitStructurePayloadParser(MemberShape payloadMember, StructureShape shape) {
        String dataName = symbolProvider.toMemberName(payloadMember);
        String dataSetter = "data." + dataName + " = ";
        String valueGetter = "map";
        writer
                .write("map = $T.decode(payload)", Hearth.CBOR);
        shape.accept(new MemberDeserializer(payloadMember, dataSetter, valueGetter, false));
    }

    private class MemberDeserializer extends ShapeVisitor.Default<Void> {

        private final String jsonGetter;
        private final String dataSetter;
        private final MemberShape memberShape;
        private final boolean checkRequired;

        MemberDeserializer(MemberShape memberShape,
                           String dataSetter, String jsonGetter, boolean checkRequired) {
            this.jsonGetter = jsonGetter;
            this.dataSetter = dataSetter;
            this.memberShape = memberShape;
            this.checkRequired = checkRequired;
        }

        private String checkRequired() {
            if (this.checkRequired) {
                return " unless " + jsonGetter + ".nil?";
            } else {
                return "";
            }
        }

        /**
         * For simple shapes, just copy to the data.
         */
        @Override
        protected Void getDefault(Shape shape) {
            writer.write("$L$L$L", dataSetter, jsonGetter, checkRequired());
            return null;
        }

        /**
         * For complex shapes, simply delegate to their builder.
         */
        private void defaultComplexDeserializer(Shape shape) {
            if (checkRequired) {
                writer.write("$1L$2L.parse($3L) unless $3L.nil?",
                        dataSetter, symbolProvider.toSymbol(shape).getName(),
                        jsonGetter);
            } else {
                writer.write("$1L($2L.parse($3L) unless $3L.nil?)",
                        dataSetter, symbolProvider.toSymbol(shape).getName(),
                        jsonGetter);
            }
        }

        @Override
        public Void listShape(ListShape shape) {
            defaultComplexDeserializer(shape);
            return null;
        }

        @Override
        public Void mapShape(MapShape shape) {
            defaultComplexDeserializer(shape);
            return null;
        }

        @Override
        public Void structureShape(StructureShape shape) {
            defaultComplexDeserializer(shape);
            return null;
        }

        @Override
        public Void unionShape(UnionShape shape) {
            defaultComplexDeserializer(shape);
            return null;
        }
    }
}
