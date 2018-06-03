# frozen_string_literal: true

require 'spec_helper'

describe Crystalball::SourceDiff::FormattingChecker do
  describe '.pure_formatting?' do
    subject { described_class.pure_formatting?(file_diff) }
    let(:file_diff) { double(path: 'lib/crystalball.rb', patch: "+  \n-\t") }

    it { is_expected.to eq true }

    context 'when patch contains real changes' do
      let(:file_diff) { Git::Diff::DiffFile.new(Git::Base.new, type: 'modified', path: 'lib/crystalball.rb', patch: " 'some here'\n+ 's'\n-'a'\t") }

      it { is_expected.to eq false }
    end

    context 'when patch contains comment only' do
      let(:file_diff) { Git::Diff::DiffFile.new(Git::Base.new, type: 'modified', path: 'lib/crystalball.rb', patch: " 'some here'\n+ # one\n- # another") }

      it { is_expected.to eq true }
    end
  end
end
