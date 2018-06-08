# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/factory_bot'

describe Crystalball::MapGenerator::FactoryBotStrategy::DSLPatch do
  subject(:instance) do
    Class.new do
      include Crystalball::MapGenerator::FactoryBotStrategy::DSLPatch

      def cb_original_factory(*); end
    end.new
  end

  context 'FactoryBot::Syntax::Default::DSL patching' do
    let!(:patched_class) do
      stub_const(
        '::FactoryBot::Syntax::Default::DSL',
        Class.new do
          def factory(*); end
        end
      )
    end

    it 'changes and restores factory method' do
      original_factory = patched_class.instance_method(:factory)
      described_class.apply!
      expect(patched_class.instance_method(:factory)).not_to eq original_factory
      described_class.revert!
      expect(patched_class.instance_method(:factory)).to eq original_factory
    end
  end

  describe '#cb_patched_factory' do
    subject { instance.cb_patched_factory(:dummy) }
    let(:factory_definitions) { {} }

    before do
      allow(Crystalball::MapGenerator::FactoryBotStrategy).to receive(:factory_definitions) { factory_definitions }
      allow(instance).to receive(:caller).and_return(['file:12:in somewhere'])
    end

    it do
      expect(instance).to receive(:cb_original_factory).with(:dummy)
      expect { subject }.to change { factory_definitions }.from({}).to('dummy' => 'file')
    end
  end
end
