# frozen_string_literal: true

require_relative 'feature_helper'

describe 'RSpec runner' do
  subject(:execute_runner) do
    Dir.chdir(root) { `bundle exec crystalball 2>&1`.strip }
  end
  include_context 'simple git repository'
  let(:important_class_path) { root.join('lib/important_class.rb') }
  let(:other_important_class_path) { root.join('lib/other_important_class.rb') }

  it 'predicts examples' do
    change class1_path

    is_expected.to match(%r{Prediction:.*(spec/class1_spec.rb|spec/file_spec.rb)})
  end

  it 'checks limit' do
    change class1_path

    is_expected.to match(/Prediction size \d+ is over the limit \(1\)/)
      .and match(/Prediction is pruned to fit the limit!/)
      .and match(/1 example, 0 failures/)
  end

  context 'when file, spec id, and directory are predicted' do
    before do
      ENV['CRYSTALBALL_EXAMPLES_LIMIT'] = '20'
    end

    after do
      ENV['CRYSTALBALL_EXAMPLES_LIMIT'] = nil
    end

    it 'removes the filters' do
      change important_class_path
      change other_important_class_path
      change class1_path

      is_expected.to match(%r{Prediction:\ \./spec/class2_spec.rb ./spec/important_dir/})
      is_expected.not_to match(%r{\./spec/class2_spec.rb\[1:1:1\]})
    end

    context 'when the files are contained in the directories' do
      it 'only predicts the directory' do
        change other_important_class_path
        change important_class_path
        change class2_path

        is_expected.to match(%r{Prediction:.*\./spec/important_dir/})
        is_expected.not_to match(%r{\./spec/important_dir/important_spec\.rb})
      end
    end
  end
end
