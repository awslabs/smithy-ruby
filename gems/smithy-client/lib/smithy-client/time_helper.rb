# frozen_string_literal: true

require 'time'

module Smithy
  module Client
    # A module that provides helper methods to convert from Time objects to
    # specific serializable formats.
    # @api private
    module TimeHelper
      class << self
        # @param [Time] time
        # @return [String<Date Time>] The time as an ISO8601 string.
        def to_date_time(time)
          optional_ms_digits = time.subsec.zero? ? nil : 3
          time.utc.iso8601(optional_ms_digits)
        end

        # @param [Time] time
        # @return [Float<Epoch Seconds>] Returns the float value of
        #   epoch seconds with millisecond precision.
        def to_epoch_seconds(time)
          time = time.utc
          epoch_seconds = time.to_i
          epoch_seconds + ((time.nsec / 1_000_000) / 1000.0)
        end

        # @param [Time] time
        # @return [String<Http Date>] Returns the time formatted
        #   as an HTTP header date.
        def to_http_date(time)
          time.utc.httpdate
        end
      end
    end
  end
end
