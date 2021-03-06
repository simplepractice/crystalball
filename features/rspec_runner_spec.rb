# frozen_string_literal: true

require_relative 'feature_helper'

describe 'RSpec runner' do
  subject(:execute_runner) do
    Dir.chdir(root) { `bundle exec crystalball 2>&1`.strip }
  end
  include_context 'simple git repository'

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
end
