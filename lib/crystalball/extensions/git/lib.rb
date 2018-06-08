# frozen_string_literal: true

module Git
  class Lib # rubocop:disable Style/Documentation
    def merge_base(*args)
      opts = args.last.is_a?(Hash) ? args.pop : {}

      arg_opts = opts.map { |k, v| "--#{k}" if v }.compact + args

      command('merge-base', arg_opts)
    end
  end
end
