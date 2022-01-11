# frozen_string_literal: true

# WARNING ABOUT GENERATED CODE
#
# This file was code generated using smithy-ruby.
# https://github.com/awslabs/smithy-ruby
#
# WARNING ABOUT GENERATED CODE

require 'base64'

module Weather
  module Builders

    # Operation Builder for GetCity
    class GetCity
      def self.build(http_req, input:)
      end
    end

    # Operation Builder for GetCityAnnouncements
    class GetCityAnnouncements
      def self.build(http_req, input:)
      end
    end

    # Operation Builder for GetCityImage
    class GetCityImage
      def self.build(http_req, input:)
      end
    end

    # Structure Builder for ImageType
    class ImageType
      def self.build(input)
        data = {}
        case input
        when Types::ImageType::Raw
        when Types::ImageType::Png
        else
          raise ArgumentError,
          "Expected input to be one of the subclasses of Types::ImageType"
        end

        data
      end
    end

    # Structure Builder for PNGImage
    class PNGImage
      def self.build(input)
        data = {}
        data
      end
    end

    # Operation Builder for GetCurrentTime
    class GetCurrentTime
      def self.build(http_req, input:)
      end
    end

    # Operation Builder for GetForecast
    class GetForecast
      def self.build(http_req, input:)
      end
    end

    # Operation Builder for ListCities
    class ListCities
      def self.build(http_req, input:)
      end
    end

    # Operation Builder for __789BadName
    class Operation__789BadName
      def self.build(http_req, input:)
      end
    end

    # Structure Builder for __456efg
    class Struct__456efg
      def self.build(input)
        data = {}
        data
      end
    end
  end
end
