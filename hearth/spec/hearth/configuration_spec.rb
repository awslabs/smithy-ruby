# frozen_string_literal: true

module Hearth
  describe Configuration do
    let(:config_class) do
      Struct.new(
        :option,
        keyword_init: true
      ) do
        include Hearth::Configuration

        private

        def validate!
          Hearth::Validator.validate!(
            option, String, context: 'options[:option]'
          )
        end

        def self.defaults
          @defaults ||= {}
        end
      end
    end

    describe '#initialize' do
      it 'uses the config resolver and validates the config object' do
        options = { option: 'test' }
        expect(Hearth::Config::Resolver).to receive(:resolve)
          .with(an_instance_of(config_class), options, config_class.defaults)
        expect_any_instance_of(config_class).to receive(:validate!)
          .and_call_original

        config_class.new(**options)
      end
    end
  end
end
