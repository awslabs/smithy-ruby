# frozen_string_literal: true

require 'cgi'
require 'ipaddr'
require 'uri'

module Smithy
  module Client
    # Functions in the Smithy rules engine are named routines that
    # operate on a finite set of specified inputs, returning an output.
    # The rules engine has a set of included functions that can be
    # invoked without additional dependencies, called the standard library.
    module EndpointRules
      # Regex that extracts anything in square brackets
      BRACKET_REGEX = /\[(.*?)\]/

      # An Endpoint resolved by an EndpointProvider
      class Endpoint
        # @param [String] :uri
        # @param [Array<AuthScheme>] :auth_schemes ([])
        # @param [Hash] :headers ({})
        def initialize(uri:, properties: {}, headers: {})
          @uri = uri
          @properties = properties
          @headers = headers
        end

        # The URI of the endpoint.
        # @return [String]
        attr_accessor :uri

        # The authentication schemes supported by the endpoint.
        # @return [Hash]
        attr_accessor :properties

        # The headers to include in requests to the endpoint.
        # @return [Hash]
        attr_accessor :headers
      end

      # Evaluates whether the input string is a compliant RFC 1123 host segment.
      # When allowSubDomains is true, evaluates whether the input string is
      # composed of values that are each compliant RFC 1123 host segments
      # joined by dot (.) characters.
      # @api private
      def self.valid_host_label?(value, allow_sub_domains)
        return false if value.empty?

        if allow_sub_domains
          labels = value.split('.', -1)
          return labels.all? { |l| valid_host_label?(l, false) }
        end

        !!(value =~ /\A(?!-)[a-zA-Z0-9-]{1,63}(?<!-)\z/)
      end

      # Computes a URL structure given an input string.
      # @api private
      def self.parse_url(value)
        URL.new(value).as_json
      rescue ArgumentError, URI::InvalidURIError
        nil
      end

      # Computes a portion of a given string based on
      # the provided start and end indices.
      # @api private
      def self.substring(input, start, stop, reverse)
        return nil if start >= stop || input.size < stop

        return nil if input.chars.any? { |c| c.ord > 127 }

        return input[start...stop] unless reverse

        r_start = input.size - stop
        r_stop = input.size - start
        input[r_start...r_stop]
      end

      # Performs RFC 3986#section-2.1 defined percent-encoding on the input value.
      # @api private
      def self.uri_encode(value)
        CGI.escape(value.encode('UTF-8')).gsub('+', '%20').gsub('%7E', '~')
      end

      # isSet(value: Option<T>) bool
      # @api private
      def self.set?(value)
        !value.nil?
      end

      # not(value: bool) bool
      # @api private
      def self.not(bool)
        !bool
      end

      # getAttr(value: Object | Array, path: string) Document
      # @api private
      def self.attr(value, path)
        parts = path.split('.')

        val = attr_brackets(parts, value)

        if parts.size == 1
          val
        else
          attr_reader(val, parts.slice(1..-1).join('.'))
        end
      end

      # stringEquals(value1: string, value2: string) bool
      # @api private
      def self.string_equals?(value1, value2)
        value1 == value2
      end

      # booleanEquals(value1: bool, value2: bool) bool
      # @api private
      def self.boolean_equals?(value1, value2)
        value1 == value2
      end

      # @api private
      class URL
        def initialize(url)
          uri = URI(url)
          @scheme = uri.scheme
          # only support http and https schemes
          raise ArgumentError unless %w[https http].include?(@scheme)

          # do not support query
          raise ArgumentError if uri.query

          @authority = extract_authority(url, uri)
          @path = uri.path
          @normalized_path = uri.path + (uri.path[-1] == '/' ? '' : '/')
          @is_ip = ip?(uri.host)
        end

        attr_reader :scheme, :authority, :path, :normalized_path, :is_ip

        def as_json(*)
          {
            'scheme' => scheme,
            'authority' => authority,
            'path' => path,
            'normalizedPath' => normalized_path,
            'isIp' => is_ip
          }
        end

        private

        def extract_authority(url, uri)
          # don't include port if it's default and not parsed originally
          if uri.default_port == uri.port && !url.include?(":#{uri.port}")
            uri.host
          else
            "#{uri.host}:#{uri.port}"
          end
        end

        def ip?(authority)
          IPAddr.new(authority)
          true
        rescue IPAddr::InvalidAddressError
          false
        end
      end

      def self.attr_brackets(parts, value)
        if (index = parts.first[BRACKET_REGEX, 1])
          # remove brackets and index from part before indexing
          if (base = parts.first.gsub(BRACKET_REGEX, '')) && !base.empty?
            value[base][index.to_i]
          else
            value[index.to_i]
          end
        else
          value[parts.first]
        end
      end
    end
  end
end
