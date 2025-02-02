# frozen_string_literal: true

module Smithy
  # The Plan class is a simple data structure that holds the model, type, and options for a generator.
  class Plan
    # @param [Hash] model The API model as a JSON hash.
    # @param [Symbol] type The type of code to generate, either :client, :server, or :schema.
    # @param [Hash] options The options passed to the generator.
    def initialize(model, type, options = {})
      @model = model
      @type = type
      @service = find_service(model['shapes'])

      @name = options.fetch(:name, default_name(service))
      @identifier = @name.downcase
      @module_name = options.fetch(:module_name, @name)
      @gem_name = options.fetch(:gem_name, default_gem_name(@module_name, @type))
      @gem_version = options.fetch(:gem_version)

      @destination_root = options.fetch(:destination_root, nil)
      @quiet = options.fetch(:quiet, false)

      Welds.load!(self)
      @welds = Welds.for(@service)
    end

    # @return [Hash] The API model as a JSON hash.
    attr_reader :model

    # @return [Symbol] The type of code to generate.
    attr_reader :type

    # @return [Hash<String, Hash>] The service shape for the shapes.
    attr_reader :service

    # @return [String] The name of the service to generate code for. (e.g. Weather)
    #  Defaults to the name of the first service shape found in the model.
    attr_reader :name

    # @return [String] The service shape identifier. (e.g. weather)
    attr_reader :identifier

    # @return [String] The gem name for clients and schemas.
    #  Defaults to a gem name derived from the module name, suffixed with '-schema' if type is schema.
    attr_reader :gem_name

    # @return [String] The version of the gem to generate.
    attr_reader :gem_version

    # @return [String] The module name for clients and schemas.
    #  Defaults to the name of the service.
    attr_reader :module_name

    # @return [String] The destination directory for the generated code.
    #  If not provided, source code will be generated to STDOUT.
    attr_reader :destination_root

    # @return [Boolean] Whether to suppress output.
    attr_reader :quiet

    # @return [Array<Weld>] The welds that apply to this plan.
    attr_reader :welds

    private

    def find_service(shapes)
      service = shapes.select { |_, shape| shape['type'] == 'service' }
      raise 'Multiple service shapes found' if service.size > 1
      raise 'No service shape found' if service.empty?

      service
    end

    def default_name(service)
      Model::Shape.name(service.keys.first)
    end

    def default_gem_name(module_name, type)
      gem_name = Util::Namespace.gem_name_from_namespace(module_name)
      type == :schema ? "#{gem_name}-schema" : gem_name
    end
  end
end
