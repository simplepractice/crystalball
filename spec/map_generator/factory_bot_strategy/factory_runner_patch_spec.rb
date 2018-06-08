# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/factory_bot'

describe Crystalball::MapGenerator::FactoryBotStrategy::FactoryRunnerPatch do
  subject(:instance) do
    Class.new do
      include Crystalball::MapGenerator::FactoryBotStrategy::FactoryRunnerPatch

      def cb_original_run(*); end
    end.new
  end

  context 'FactoryBot::FactoryRunner patching' do
    let!(:patched_class) do
      stub_const(
        '::FactoryBot::FactoryRunner',
        Class.new do
          def run(*); end
        end
      )
    end

    it 'changes and restores run method' do
      original_run = patched_class.instance_method(:run)
      described_class.apply!
      expect(patched_class.instance_method(:run)).not_to eq original_run
      described_class.revert!
      expect(patched_class.instance_method(:run)).to eq original_run
    end
  end

  describe '#cb_patched_run' do
    subject { instance.cb_patched_run('args') }
    let(:used_factories) { [] }

    before do
      allow(Crystalball::MapGenerator::FactoryBotStrategy).to receive(:used_factories) { used_factories }
      allow(Crystalball::MapGenerator::FactoryBotStrategy).to receive(:factory_definitions) { {'factory' => 'file'} }
      instance.instance_variable_set(:@name, :factory)
    end

    it do
      expect(instance).to receive(:cb_original_run).with('args')
      expect { subject }.to change { used_factories }.from([]).to(['file'])
    end
  end
end
