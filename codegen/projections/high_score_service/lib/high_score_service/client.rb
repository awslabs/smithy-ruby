# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/awslabs/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

require_relative 'middleware/request_id'

module HighScoreService
  # An API client for HighScoreService
  # See {#initialize} for a full list of supported configuration options
  # Rails High Score example from their generator docs
  #
  class Client
    include Hearth::ClientStubs

    @middleware = Hearth::MiddlewareBuilder.new

    def self.middleware
      @middleware
    end

    # @overload initialize(options)
    # @param [Hash] options
    # @option options [Boolean] :disable_host_prefix (false)
    #   When `true`, does not perform host prefix injection using @endpoint's hostPrefix property.
    #
    # @option options [string] :endpoint
    #   Endpoint of the service
    #
    # @option options [bool] :http_wire_trace (false)
    #   Enable debug wire trace on http requests.
    #
    # @option options [symbol] :log_level (:info)
    #   Default log level to use
    #
    # @option options [Logger] :logger (stdout)
    #   Logger to use for output
    #
    # @option options [MiddlewareBuilder] :middleware
    #   Additional Middleware to be applied for every operation
    #
    # @option options [Bool] :stub_responses (false)
    #   Enable response stubbing. See documentation for {#stub_responses}
    #
    # @option options [Boolean] :validate_input (true)
    #   When `true`, request parameters are validated using the modeled shapes.
    #
    def initialize(options = {})
      @disable_host_prefix = options.fetch(:disable_host_prefix, false)
      @endpoint = options[:endpoint]
      @http_wire_trace = options.fetch(:http_wire_trace, false)
      @log_level = options.fetch(:log_level, :info)
      @logger = options.fetch(:logger, Logger.new($stdout, level: @log_level))
      @middleware = Hearth::MiddlewareBuilder.new(options[:middleware])
      @stub_responses = options.fetch(:stub_responses, false)
      @stubs = Hearth::Stubbing::Stubs.new
      @validate_input = options.fetch(:validate_input, true)

    end

    # Create a new high score
    #
    # @param [Hash] params
    #   See {Types::CreateHighScoreInput}.
    #
    # @option params [HighScoreParams] :high_score
    #   The high score params
    #
    # @return [Types::CreateHighScoreOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.create_high_score(
    #     high_score: {
    #       game: 'game',
    #       score: 1
    #     } # required
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::CreateHighScoreOutput
    #   resp.data.high_score #=> Types::HighScoreAttributes
    #   resp.data.high_score.id #=> String
    #   resp.data.high_score.game #=> String
    #   resp.data.high_score.score #=> Integer
    #   resp.data.high_score.created_at #=> Time
    #   resp.data.high_score.updated_at #=> Time
    #   resp.data.location #=> String
    #
    def create_high_score(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::CreateHighScoreInput.build(params)
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::CreateHighScoreInput,
        validate_input: options.fetch(:validate_input, @validate_input)
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::CreateHighScore,
        disable_host_prefix: options.fetch(:disable_host_prefix, @disable_host_prefix)
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 201, errors: [Errors::UnprocessableEntityError]),
        data_parser: Parsers::CreateHighScore
      )
      stack.use(Middleware::RequestId)
      stack.use(Hearth::Middleware::Send,
        stub_responses: options.fetch(:stub_responses, @stub_responses),
        client: Hearth::HTTP::Client.new(logger: @logger, http_wire_trace: options.fetch(:http_wire_trace, @http_wire_trace)),
        stub_class: Stubs::CreateHighScore,
        params_class: Params::CreateHighScoreOutput,
        stubs: options.fetch(:stubs, @stubs)
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @endpoint)),
          response: Hearth::HTTP::Response.new(body: output_stream(options, &block)),
          params: params,
          logger: @logger,
          operation_name: :create_high_score
        )
      )
      raise resp.error if resp.error
      resp
    end

    # Delete a high score
    #
    # @param [Hash] params
    #   See {Types::DeleteHighScoreInput}.
    #
    # @option params [String] :id
    #   The high score id
    #
    # @return [Types::DeleteHighScoreOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.delete_high_score(
    #     id: 'id' # required
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::DeleteHighScoreOutput
    #
    def delete_high_score(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::DeleteHighScoreInput.build(params)
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::DeleteHighScoreInput,
        validate_input: options.fetch(:validate_input, @validate_input)
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::DeleteHighScore,
        disable_host_prefix: options.fetch(:disable_host_prefix, @disable_host_prefix)
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::DeleteHighScore
      )
      stack.use(Middleware::RequestId)
      stack.use(Hearth::Middleware::Send,
        stub_responses: options.fetch(:stub_responses, @stub_responses),
        client: Hearth::HTTP::Client.new(logger: @logger, http_wire_trace: options.fetch(:http_wire_trace, @http_wire_trace)),
        stub_class: Stubs::DeleteHighScore,
        params_class: Params::DeleteHighScoreOutput,
        stubs: options.fetch(:stubs, @stubs)
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @endpoint)),
          response: Hearth::HTTP::Response.new(body: output_stream(options, &block)),
          params: params,
          logger: @logger,
          operation_name: :delete_high_score
        )
      )
      raise resp.error if resp.error
      resp
    end

    # Get a high score
    #
    # @param [Hash] params
    #   See {Types::GetHighScoreInput}.
    #
    # @option params [String] :id
    #   The high score id
    #
    # @return [Types::GetHighScoreOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.get_high_score(
    #     id: 'id' # required
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::GetHighScoreOutput
    #   resp.data.high_score #=> Types::HighScoreAttributes
    #   resp.data.high_score.id #=> String
    #   resp.data.high_score.game #=> String
    #   resp.data.high_score.score #=> Integer
    #   resp.data.high_score.created_at #=> Time
    #   resp.data.high_score.updated_at #=> Time
    #
    def get_high_score(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::GetHighScoreInput.build(params)
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::GetHighScoreInput,
        validate_input: options.fetch(:validate_input, @validate_input)
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::GetHighScore,
        disable_host_prefix: options.fetch(:disable_host_prefix, @disable_host_prefix)
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::GetHighScore
      )
      stack.use(Middleware::RequestId)
      stack.use(Hearth::Middleware::Send,
        stub_responses: options.fetch(:stub_responses, @stub_responses),
        client: Hearth::HTTP::Client.new(logger: @logger, http_wire_trace: options.fetch(:http_wire_trace, @http_wire_trace)),
        stub_class: Stubs::GetHighScore,
        params_class: Params::GetHighScoreOutput,
        stubs: options.fetch(:stubs, @stubs)
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @endpoint)),
          response: Hearth::HTTP::Response.new(body: output_stream(options, &block)),
          params: params,
          logger: @logger,
          operation_name: :get_high_score
        )
      )
      raise resp.error if resp.error
      resp
    end

    # List all high scores
    #
    # @param [Hash] params
    #   See {Types::ListHighScoresInput}.
    #
    # @return [Types::ListHighScoresOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.list_high_scores()
    #
    # @example Response structure
    #
    #   resp.data #=> Types::ListHighScoresOutput
    #   resp.data.high_scores #=> Array<HighScoreAttributes>
    #   resp.data.high_scores[0] #=> Types::HighScoreAttributes
    #   resp.data.high_scores[0].id #=> String
    #   resp.data.high_scores[0].game #=> String
    #   resp.data.high_scores[0].score #=> Integer
    #   resp.data.high_scores[0].created_at #=> Time
    #   resp.data.high_scores[0].updated_at #=> Time
    #
    def list_high_scores(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::ListHighScoresInput.build(params)
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::ListHighScoresInput,
        validate_input: options.fetch(:validate_input, @validate_input)
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::ListHighScores,
        disable_host_prefix: options.fetch(:disable_host_prefix, @disable_host_prefix)
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: []),
        data_parser: Parsers::ListHighScores
      )
      stack.use(Middleware::RequestId)
      stack.use(Hearth::Middleware::Send,
        stub_responses: options.fetch(:stub_responses, @stub_responses),
        client: Hearth::HTTP::Client.new(logger: @logger, http_wire_trace: options.fetch(:http_wire_trace, @http_wire_trace)),
        stub_class: Stubs::ListHighScores,
        params_class: Params::ListHighScoresOutput,
        stubs: options.fetch(:stubs, @stubs)
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @endpoint)),
          response: Hearth::HTTP::Response.new(body: output_stream(options, &block)),
          params: params,
          logger: @logger,
          operation_name: :list_high_scores
        )
      )
      raise resp.error if resp.error
      resp
    end

    # Update a high score
    #
    # @param [Hash] params
    #   See {Types::UpdateHighScoreInput}.
    #
    # @option params [String] :id
    #   The high score id
    #
    # @option params [HighScoreParams] :high_score
    #   The high score params
    #
    # @return [Types::UpdateHighScoreOutput]
    #
    # @example Request syntax with placeholder values
    #
    #   resp = client.update_high_score(
    #     id: 'id', # required
    #     high_score: {
    #       game: 'game',
    #       score: 1
    #     }
    #   )
    #
    # @example Response structure
    #
    #   resp.data #=> Types::UpdateHighScoreOutput
    #   resp.data.high_score #=> Types::HighScoreAttributes
    #   resp.data.high_score.id #=> String
    #   resp.data.high_score.game #=> String
    #   resp.data.high_score.score #=> Integer
    #   resp.data.high_score.created_at #=> Time
    #   resp.data.high_score.updated_at #=> Time
    #
    def update_high_score(params = {}, options = {}, &block)
      stack = Hearth::MiddlewareStack.new
      input = Params::UpdateHighScoreInput.build(params)
      stack.use(Hearth::Middleware::Validate,
        validator: Validators::UpdateHighScoreInput,
        validate_input: options.fetch(:validate_input, @validate_input)
      )
      stack.use(Hearth::Middleware::Build,
        builder: Builders::UpdateHighScore,
        disable_host_prefix: options.fetch(:disable_host_prefix, @disable_host_prefix)
      )
      stack.use(Hearth::HTTP::Middleware::ContentLength)
      stack.use(Hearth::Middleware::Parse,
        error_parser: Hearth::HTTP::ErrorParser.new(error_module: Errors, success_status: 200, errors: [Errors::UnprocessableEntityError]),
        data_parser: Parsers::UpdateHighScore
      )
      stack.use(Middleware::RequestId)
      stack.use(Hearth::Middleware::Send,
        stub_responses: options.fetch(:stub_responses, @stub_responses),
        client: Hearth::HTTP::Client.new(logger: @logger, http_wire_trace: options.fetch(:http_wire_trace, @http_wire_trace)),
        stub_class: Stubs::UpdateHighScore,
        params_class: Params::UpdateHighScoreOutput,
        stubs: options.fetch(:stubs, @stubs)
      )
      apply_middleware(stack, options[:middleware])

      resp = stack.run(
        input: input,
        context: Hearth::Context.new(
          request: Hearth::HTTP::Request.new(url: options.fetch(:endpoint, @endpoint)),
          response: Hearth::HTTP::Response.new(body: output_stream(options, &block)),
          params: params,
          logger: @logger,
          operation_name: :update_high_score
        )
      )
      raise resp.error if resp.error
      resp
    end

    private

    def apply_middleware(middleware_stack, middleware)
      Client.middleware.apply(middleware_stack)
      @middleware.apply(middleware_stack)
      Hearth::MiddlewareBuilder.new(middleware).apply(middleware_stack)
    end

    def output_stream(options = {}, &block)
      return options[:output_stream] if options[:output_stream]
      return Hearth::BlockIO.new(block) if block

      StringIO.new
    end
  end
end
