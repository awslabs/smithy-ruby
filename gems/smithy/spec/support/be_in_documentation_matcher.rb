# frozen_string_literal: true

require 'rdoc'

RSpec::Matchers.define :be_in_documentation do |file, klass, method|
  match do |expected|
    rdoc = RDoc::RDoc.new
    rdoc.options = RDoc::Options.load_options
    rdoc.store = RDoc::Store.new
    top_level = rdoc.parse_files([file]).first
    documentation = top_level.find_class_or_module(klass)
    documentation = documentation.find_method_named(method) if method
    @actual = documentation.comment.text
    @expected = expected.chomp
    expect(@actual).to include(@expected)
  end

  failure_message do
    differ = RSpec::Support::Differ.new
    differ.diff(@expected, @actual)
  end
end
