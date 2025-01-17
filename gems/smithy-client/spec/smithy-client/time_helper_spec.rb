# frozen_string_literal: true

module Smithy
  module Client
    describe TimeHelper do
      let(:time) { Time.utc(1970, 1, 1) }

      describe '.to_date_time' do
        it 'converts a time object to date time format' do
          expect(subject.to_date_time(time)).to eq '1970-01-01T00:00:00Z'
        end

        context 'fractional seconds' do
          let(:time) { Time.at(946_845_296, 123, :millisecond) }
          it 'converts to date time format with milliseconds' do
            expect(subject.to_date_time(time)).to eq '2000-01-02T20:34:56.123Z'
          end
        end
      end

      describe '.to_epoch_seconds' do
        it 'converts a time object to epoch seconds format' do
          expect(subject.to_epoch_seconds(time)).to eq 0.0
        end

        context 'fractional seconds' do
          let(:time) { Time.at(946_845_296, 123, :millisecond) }
          it 'converts to date time format with milliseconds' do
            expect(subject.to_epoch_seconds(time)).to eq 946_845_296.123
          end
        end
      end

      describe '.to_http_date' do
        it 'converts a time object to http date format' do
          expect(subject.to_http_date(time)).to eq 'Thu, 01 Jan 1970 00:00:00 GMT'
        end

        context 'fractional seconds' do
          let(:time) { Time.at(946_845_296, 123, :millisecond) }
          it 'converts to http date format without milliseconds' do
            expect(subject.to_http_date(time))
              .to eq 'Sun, 02 Jan 2000 20:34:56 GMT'
          end
        end
      end
    end
  end
end
