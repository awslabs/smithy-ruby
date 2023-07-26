# frozen_string_literal: true

module Hearth
  module HTTP
    module Middleware
      # A middleware that compresses the request body and
      # adds the Content-Encoding header
      # @api private
      class RequestCompression
        SUPPORTED_ENCODINGS = %w[gzip].freeze
        CHUNK_SIZE = 1 * 1024 * 1024 # one MB

        def initialize(app,
                       disable_request_compression:,
                       request_min_compression_size_bytes:,
                       encodings:,
                       streaming:)
          @app = app
          @disable_request_compression = disable_request_compression
          @request_min_compression_size_bytes =
            request_min_compression_size_bytes
          @encodings = encodings
          @streaming = streaming
        end

        # @param input
        # @param context
        # @return [Output]
        def call(input, context)
          request = context.request
          unless @disable_request_compression
            selected_encoding = request_encoding_selection(@encodings)
            if selected_encoding
              if @streaming
                process_streaming_compression(selected_encoding, request)
              elsif request.body.size >= @request_min_compression_size_bytes
                process_compression(selected_encoding, request)
              end
            end
          end
          @app.call(input, context)
        end

        private

        def request_encoding_selection(encodings)
          encodings.find { |encoding| SUPPORTED_ENCODINGS.include?(encoding) }
        end

        def update_content_encoding(encoding, request)
          headers = request.headers
          if headers['Content-Encoding']
            headers['Content-Encoding'] += ",#{encoding}"
          else
            headers['Content-Encoding'] = encoding
          end
        end

        def process_compression(encoding, request)
          case encoding
          when 'gzip'
            gzip_compress(request)
          else
            raise 'We currently do not support ' \
                  "#{encoding} encoding"
          end
          update_content_encoding(encoding, request)
        end

        def gzip_compress(request)
          compressed = StringIO.new
          compressed.binmode
          gzip_writer = Zlib::GzipWriter.new(compressed)
          if request.body.respond_to?(:read)
            update_in_chunks(gzip_writer, request.body)
          else
            gzip_writer.write(request.body)
          end
          gzip_writer.close
          new_body = StringIO.new(compressed.string)
          request.body = new_body
        end

        def update_in_chunks(compressor, io)
          loop do
            chunk = io.read(CHUNK_SIZE)
            break unless chunk

            compressor.write(chunk)
          end
        end

        def process_streaming_compression(encoding, request)
          case encoding
          when 'gzip'
            request.body = GzipIO.new(request.body)
          else
            raise 'We currently do not support ' \
                  "#{encoding} encoding"
          end
          update_content_encoding(encoding, request)
        end

        # @api private
        class GzipIO
          def initialize(body)
            @body = body
            @buffer = ChunkBuffer.new
            @gzip_writer = Zlib::GzipWriter.new(@buffer)
          end

          def read(length, buff = nil)
            if @gzip_writer.closed?
              # an empty string to signify an end as
              # there will be nothing remaining to be read
              StringIO.new('').read(length, buff)
              return
            end

            chunk = @body.read(length)
            if !chunk || chunk.empty?
              # closing the writer will write one last chunk
              # with a trailer (to be read from the @buffer)
              @gzip_writer.close
            else
              # flush happens first to ensure that header fields
              # are being sent over since write will override
              @gzip_writer.flush
              @gzip_writer.write(chunk)
            end

            StringIO.new(@buffer.last_chunk).read(length, buff)
          end
        end

        # @api private
        class ChunkBuffer
          def initialize
            @last_chunk = nil
          end

          attr_reader :last_chunk

          def write(data)
            @last_chunk = data
          end
        end
      end
    end
  end
end
