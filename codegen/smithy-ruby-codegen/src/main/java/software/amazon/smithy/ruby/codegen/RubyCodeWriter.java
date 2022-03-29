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

package software.amazon.smithy.ruby.codegen;

import java.util.function.Consumer;
import software.amazon.smithy.utils.AbstractCodeWriter;
import software.amazon.smithy.utils.SmithyUnstableApi;

/**
 * A helper class for generating well formatted Ruby code.
 */
@SmithyUnstableApi
public class RubyCodeWriter extends AbstractCodeWriter<RubyCodeWriter> {

    public RubyCodeWriter() {
        trimTrailingSpaces();
        trimBlankLines();
        setIndentText("  ");
    }

    /**
     * Writes preamble comments.
     * For writers that are used to generate full files, this should
     * be called before any other write methods.
     *
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writePreamble() {
        write("# frozen_string_literal: true\n");
        write("# WARNING ABOUT GENERATED CODE");
        write("#");
        write("# This file was code generated using smithy-ruby.");
        write("# https://github.com/awslabs/smithy-ruby");
        write("#");
        write("# WARNING ABOUT GENERATED CODE\n");
        return this;
    }

    /**
     * Sets formatting for writing Rdoc doc comments.
     *
     * @param consumer All lines written by the task will be prefixed with the comment string.
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeDocs(Consumer<RubyCodeWriter> consumer) {
        pushState();
        setNewlinePrefix("# ");
        consumer.accept(this);
        popState();
        return this;
    }

    /*
     * YARD convenience methods
     */

    /**
     * Writes a yard attribute tag.
     *
     * @param attribute name of the attribute
     * @param task      lines written by the task are properly indented
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeYardAttribute(String attribute, Runnable task) {
        writeDocs((w) -> {
            w.write("@!attribute $L", attribute);
            w.pushFilteredState(s -> s.replace("#", " "));
            task.run();
            w.popState();
        });
        return this;
    }

    /**
     * Write a docstring.
     *
     * @param docstring the docstring to write.
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeDocstring(String docstring) {
        writeDocs((w) -> {
            w.write("$L", docstring);
            w.write("");
        });
        return this;
    }

    /**
     * Writes a yard param.
     *
     * @param returnType    the Ruby Type
     * @param param         name of the parameter
     * @param documentation documentation to write
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeYardParam(String returnType, String param, String documentation) {
        writeDocs((w) -> {
            w.write("@param [$L] $L", returnType, param);
            w.writeIndentedParts(documentation);
            w.write("");
        });
        return this;
    }

    /**
     * Writes a Yard option.
     *
     * @param param         the name of the param
     * @param type          the Ruby type of the param
     * @param option        name of the option
     * @param defaultValue  default value for the param
     * @param documentation documentation to write
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeYardOption(String param, String type, String option, String defaultValue,
                                          String documentation) {
        writeDocs((w) -> {
            w.writeInline("@option $L [$L] $L", param, type, option);
            if (!defaultValue.isEmpty()) {
                w.write(" ($L)", defaultValue);
            } else {
                w.write("");
            }
            w.writeIndentedParts(documentation);
            w.write("");
        });
        return this;
    }

    /**
     * Writes a Yard return.
     *
     * @param returnType    the Ruby type
     * @param documentation documentation to write
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeYardReturn(String returnType, String documentation) {
        writeDocs((w) -> {
            w.write("@return [$L]", returnType);
            w.writeIndentedParts(documentation);
            w.write("");
        });
        return this;
    }

    /**
     * Writes a Yard example.
     *
     * @param title title for the example
     * @param block lines in the block will be properly indented
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeYardExample(String title, String block) {
        writeDocs((w) -> {
            w.write("@example $L", title);
            w.write("");
            w.writeIndentedParts(block);
            w.write("");
        });
        return this;
    }

    /**
     * Writes a yard deprecated tag.
     *
     * @param message deprecation message
     * @param since   deprecated since
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeYardDeprecated(String message, String since) {
        writeDocs((w) -> {
            w.write("@deprecated");
            w.writeIndentedParts(message);
            if (!since.isEmpty()) {
                w.write("  Since: $L", since);
            }
            w.write("");
        });
        return this;
    }

    /**
     * Writes a yard see tag.
     *
     * @param url         url to see
     * @param description description of the url
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeYardSee(String url, String description) {
        writeDocs((w) -> {
            w.write("@see $L $L", url, description);
            w.write("");
        });
        return this;
    }

    /**
     * Writes a yard note.
     *
     * @param note the note to write
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeYardNote(String note) {
        writeDocs((w) -> {
            w.write("@note");
            w.writeIndentedParts(note);
            w.write("");
        });
        return this;
    }

    /**
     * Writes a yard since tag.
     *
     * @param since since to write
     * @return Returns the CodeWriter
     */
    public RubyCodeWriter writeYardSince(String since) {
        writeDocs((w) -> {
            w.write("@since $L", since);
            w.write("");
        });
        return this;
    }

    // Writes a documentation indented newline separated string
    private void writeIndentedParts(String documentation) {
        if (!documentation.isEmpty()) {
            String[] docstringParts = documentation.split("\n");
            for (int i = 0; i < docstringParts.length; i++) {
                write("  $L", docstringParts[i]);
            }
        }
    }
}
