# frozen_string_literal: true

require 'spec_helper'
require 'crystalball/factory_bot'

describe Crystalball::MapGenerator::FactoryBotStrategy do
  subject(:strategy) { described_class.new }

  include_examples 'base strategy'

  describe '#after_start' do
    subject { strategy.after_start }

    it do
      expect(Crystalball::MapGenerator::FactoryBotStrategy::DSLPatch).to receive(:apply!)
      expect(Crystalball::MapGenerator::FactoryBotStrategy::FactoryRunnerPatch).to receive(:apply!)
      subject
    end
  end

  describe '#before_finalize' do
    subject { strategy.before_finalize }

    specify do
      expect(Crystalball::MapGenerator::FactoryBotStrategy::DSLPatch).to receive(:revert!)
      expect(Crystalball::MapGenerator::FactoryBotStrategy::FactoryRunnerPatch).to receive(:revert!)
      subject
    end
  end

  describe '#call' do
    let(:case_map) { [] }

    it 'pushes affected files to case map' do
      allow(strategy).to receive(:filter).with(['factory']).and_return([1, 2, 3])

      expect do
        subject.call(case_map, 'example') do
          Crystalball::MapGenerator::FactoryBotStrategy.used_factories.push 'factory'
        end
      end.to change { case_map }.to [1, 2, 3]
    end

    it 'yields case_map to a block' do
      allow(strategy).to receive(:filter).with([]).and_return([])

      expect do |b|
        subject.call(case_map, 'example', &b)
      end.to yield_with_args(case_map)
    end
  end
end
