# frozen_string_literal: true

module Smithy
  module Command
    describe CLI do
      subject { described_class.new([], destination_root: '') }

      it 'shows usage for smith client' do
        expect { subject.smith }.to output(/smith client/).to_stdout
      end

      it 'shows usage for smith types' do
        expect { subject.smith }.to output(/smith types/).to_stdout
      end

      it 'shows usage for smith server' do
        expect { subject.smith }.to output(/smith server/).to_stdout
      end
    end

    describe Smith do
      subject { described_class.new([], destination_root: '') }

      it 'has a types option' do
        expect(subject).to respond_to(:schema)
      end

      it 'has a client option' do
        expect(subject).to respond_to(:client)
      end

      it 'has a server option' do
        expect(subject).to respond_to(:server)
      end
    end
  end
end
