# frozen_string_literal: true

module Git
  class Base # rubocop:disable Style/Documentation
    def merge_base(*args)
      gcommit(lib.merge_base(*args))
    end
  end
end
