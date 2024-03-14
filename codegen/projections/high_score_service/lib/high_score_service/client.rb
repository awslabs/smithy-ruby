# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/smithy-lang/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

require 'stringio'

module HighScoreService
  # Rails High Score example from their generator docs
  class Client
    include Hearth::ClientStubs

    # @api private
    @plugins = Hearth::PluginList.new

    # @return [Hearth::PluginList]
    def self.plugins
      @plugins
    end

    # @param [Hash] options
    #   Options used to construct an instance of {Config}
    def initialize(options = {})
      @config = initialize_config(options)
      @stubs = Hearth::Stubs.new
    end

    # @return [Config] config
    attr_reader :config

    # @param [Hash | Types::ApiKeyAuthInput] params
    #   Request parameters for this operation.
    #   See {Types::ApiKeyAuthInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Types::ApiKeyAuthOutput]
    # @example Request syntax with placeholder values
    #   resp = client.api_key_auth()
    # @example Response structure
    #   resp.data #=> Types::ApiKeyAuthOutput
    def api_key_auth(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::ApiKeyAuthInput.build(params, context: 'params')
      stack = HighScoreService::Middleware::ApiKeyAuth.build(config, @stubs)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        logger: config.logger,
        operation_name: :api_key_auth,
        interceptors: config.interceptors
      )
      context.logger.info("[#{context.invocation_id}] [#{self.class}#api_key_auth] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.logger.error("[#{context.invocation_id}] [#{self.class}#api_key_auth] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.logger.info("[#{context.invocation_id}] [#{self.class}#api_key_auth] #{output.data}")
      output
    end

    # @param [Hash | Types::BasicAuthInput] params
    #   Request parameters for this operation.
    #   See {Types::BasicAuthInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Types::BasicAuthOutput]
    # @example Request syntax with placeholder values
    #   resp = client.basic_auth()
    # @example Response structure
    #   resp.data #=> Types::BasicAuthOutput
    def basic_auth(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::BasicAuthInput.build(params, context: 'params')
      stack = HighScoreService::Middleware::BasicAuth.build(config, @stubs)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        logger: config.logger,
        operation_name: :basic_auth,
        interceptors: config.interceptors
      )
      context.logger.info("[#{context.invocation_id}] [#{self.class}#basic_auth] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.logger.error("[#{context.invocation_id}] [#{self.class}#basic_auth] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.logger.info("[#{context.invocation_id}] [#{self.class}#basic_auth] #{output.data}")
      output
    end

    # @param [Hash | Types::BearerAuthInput] params
    #   Request parameters for this operation.
    #   See {Types::BearerAuthInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Types::BearerAuthOutput]
    # @example Request syntax with placeholder values
    #   resp = client.bearer_auth()
    # @example Response structure
    #   resp.data #=> Types::BearerAuthOutput
    def bearer_auth(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::BearerAuthInput.build(params, context: 'params')
      stack = HighScoreService::Middleware::BearerAuth.build(config, @stubs)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        logger: config.logger,
        operation_name: :bearer_auth,
        interceptors: config.interceptors
      )
      context.logger.info("[#{context.invocation_id}] [#{self.class}#bearer_auth] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.logger.error("[#{context.invocation_id}] [#{self.class}#bearer_auth] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.logger.info("[#{context.invocation_id}] [#{self.class}#bearer_auth] #{output.data}")
      output
    end

    # Create a new high score
    # @param [Hash | Types::CreateHighScoreInput] params
    #   Request parameters for this operation.
    #   See {Types::CreateHighScoreInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Types::CreateHighScoreOutput]
    # @example Request syntax with placeholder values
    #   resp = client.create_high_score(
    #     high_score: {
    #       game: 'game',
    #       score: 1
    #     } # required
    #   )
    # @example Response structure
    #   resp.data #=> Types::CreateHighScoreOutput
    #   resp.data.high_score #=> Types::HighScoreAttributes
    #   resp.data.high_score.id #=> String
    #   resp.data.high_score.game #=> String
    #   resp.data.high_score.score #=> Integer
    #   resp.data.high_score.created_at #=> Time
    #   resp.data.high_score.updated_at #=> Time
    #   resp.data.location #=> String
    def create_high_score(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::CreateHighScoreInput.build(params, context: 'params')
      stack = HighScoreService::Middleware::CreateHighScore.build(config, @stubs)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        logger: config.logger,
        operation_name: :create_high_score,
        interceptors: config.interceptors
      )
      context.logger.info("[#{context.invocation_id}] [#{self.class}#create_high_score] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.logger.error("[#{context.invocation_id}] [#{self.class}#create_high_score] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.logger.info("[#{context.invocation_id}] [#{self.class}#create_high_score] #{output.data}")
      output
    end

    # Delete a high score
    # @param [Hash | Types::DeleteHighScoreInput] params
    #   Request parameters for this operation.
    #   See {Types::DeleteHighScoreInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Types::DeleteHighScoreOutput]
    # @example Request syntax with placeholder values
    #   resp = client.delete_high_score(
    #     id: 'id' # required
    #   )
    # @example Response structure
    #   resp.data #=> Types::DeleteHighScoreOutput
    def delete_high_score(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::DeleteHighScoreInput.build(params, context: 'params')
      stack = HighScoreService::Middleware::DeleteHighScore.build(config, @stubs)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        logger: config.logger,
        operation_name: :delete_high_score,
        interceptors: config.interceptors
      )
      context.logger.info("[#{context.invocation_id}] [#{self.class}#delete_high_score] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.logger.error("[#{context.invocation_id}] [#{self.class}#delete_high_score] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.logger.info("[#{context.invocation_id}] [#{self.class}#delete_high_score] #{output.data}")
      output
    end

    # @param [Hash | Types::DigestAuthInput] params
    #   Request parameters for this operation.
    #   See {Types::DigestAuthInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Types::DigestAuthOutput]
    # @example Request syntax with placeholder values
    #   resp = client.digest_auth()
    # @example Response structure
    #   resp.data #=> Types::DigestAuthOutput
    def digest_auth(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::DigestAuthInput.build(params, context: 'params')
      stack = HighScoreService::Middleware::DigestAuth.build(config, @stubs)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        logger: config.logger,
        operation_name: :digest_auth,
        interceptors: config.interceptors
      )
      context.logger.info("[#{context.invocation_id}] [#{self.class}#digest_auth] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.logger.error("[#{context.invocation_id}] [#{self.class}#digest_auth] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.logger.info("[#{context.invocation_id}] [#{self.class}#digest_auth] #{output.data}")
      output
    end

    # Get a high score
    # @param [Hash | Types::GetHighScoreInput] params
    #   Request parameters for this operation.
    #   See {Types::GetHighScoreInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Types::GetHighScoreOutput]
    # @example Request syntax with placeholder values
    #   resp = client.get_high_score(
    #     id: 'id' # required
    #   )
    # @example Response structure
    #   resp.data #=> Types::GetHighScoreOutput
    #   resp.data.high_score #=> Types::HighScoreAttributes
    #   resp.data.high_score.id #=> String
    #   resp.data.high_score.game #=> String
    #   resp.data.high_score.score #=> Integer
    #   resp.data.high_score.created_at #=> Time
    #   resp.data.high_score.updated_at #=> Time
    def get_high_score(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::GetHighScoreInput.build(params, context: 'params')
      stack = HighScoreService::Middleware::GetHighScore.build(config, @stubs)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        logger: config.logger,
        operation_name: :get_high_score,
        interceptors: config.interceptors
      )
      context.logger.info("[#{context.invocation_id}] [#{self.class}#get_high_score] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.logger.error("[#{context.invocation_id}] [#{self.class}#get_high_score] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.logger.info("[#{context.invocation_id}] [#{self.class}#get_high_score] #{output.data}")
      output
    end

    # List all high scores
    # @param [Hash | Types::ListHighScoresInput] params
    #   Request parameters for this operation.
    #   See {Types::ListHighScoresInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Types::ListHighScoresOutput]
    # @example Request syntax with placeholder values
    #   resp = client.list_high_scores()
    # @example Response structure
    #   resp.data #=> Types::ListHighScoresOutput
    #   resp.data.high_scores #=> Array<HighScoreAttributes>
    #   resp.data.high_scores[0] #=> Types::HighScoreAttributes
    #   resp.data.high_scores[0].id #=> String
    #   resp.data.high_scores[0].game #=> String
    #   resp.data.high_scores[0].score #=> Integer
    #   resp.data.high_scores[0].created_at #=> Time
    #   resp.data.high_scores[0].updated_at #=> Time
    def list_high_scores(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::ListHighScoresInput.build(params, context: 'params')
      stack = HighScoreService::Middleware::ListHighScores.build(config, @stubs)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        logger: config.logger,
        operation_name: :list_high_scores,
        interceptors: config.interceptors
      )
      context.logger.info("[#{context.invocation_id}] [#{self.class}#list_high_scores] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.logger.error("[#{context.invocation_id}] [#{self.class}#list_high_scores] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.logger.info("[#{context.invocation_id}] [#{self.class}#list_high_scores] #{output.data}")
      output
    end

    # Update a high score
    # @param [Hash | Types::UpdateHighScoreInput] params
    #   Request parameters for this operation.
    #   See {Types::UpdateHighScoreInput#initialize} for available parameters.
    # @param [Hash] options
    #   Request option override of configuration. See {Config#initialize} for available options.
    #   Some configurations cannot be overridden.
    # @return [Types::UpdateHighScoreOutput]
    # @example Request syntax with placeholder values
    #   resp = client.update_high_score(
    #     id: 'id', # required
    #     high_score: {
    #       game: 'game',
    #       score: 1
    #     }
    #   )
    # @example Response structure
    #   resp.data #=> Types::UpdateHighScoreOutput
    #   resp.data.high_score #=> Types::HighScoreAttributes
    #   resp.data.high_score.id #=> String
    #   resp.data.high_score.game #=> String
    #   resp.data.high_score.score #=> Integer
    #   resp.data.high_score.created_at #=> Time
    #   resp.data.high_score.updated_at #=> Time
    def update_high_score(params = {}, options = {})
      response_body = ::StringIO.new
      config = operation_config(options)
      input = Params::UpdateHighScoreInput.build(params, context: 'params')
      stack = HighScoreService::Middleware::UpdateHighScore.build(config, @stubs)
      context = Hearth::Context.new(
        request: Hearth::HTTP::Request.new(uri: URI('')),
        response: Hearth::HTTP::Response.new(body: response_body),
        logger: config.logger,
        operation_name: :update_high_score,
        interceptors: config.interceptors
      )
      context.logger.info("[#{context.invocation_id}] [#{self.class}#update_high_score] params: #{params}, options: #{options}")
      output = stack.run(input, context)
      if output.error
        context.logger.error("[#{context.invocation_id}] [#{self.class}#update_high_score] #{output.error} (#{output.error.class})")
        raise output.error
      end
      context.logger.info("[#{context.invocation_id}] [#{self.class}#update_high_score] #{output.data}")
      output
    end

    private

    def initialize_config(options)
      client_interceptors = options.delete(:interceptors)
      config = Config.new(**options)
      Client.plugins.each { |p| p.call(config) }
      config.plugins.each { |p| p.call(config) }
      config.interceptors.concat(Hearth::InterceptorList.new(client_interceptors)) if client_interceptors
      config.validate!
      config.freeze
    end

    def operation_config(options)
      return @config if options.empty?

      operation_plugins = options.delete(:plugins)
      operation_interceptors = options.delete(:interceptors)
      config = @config.merge(options)
      Hearth::PluginList.new(operation_plugins).each { |p| p.call(config) } if operation_plugins
      config.interceptors.concat(Hearth::InterceptorList.new(operation_interceptors)) if operation_interceptors
      config.validate!
      config.freeze
    end
  end
end
