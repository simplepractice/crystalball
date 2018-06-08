# frozen_string_literal: true

require 'factory_bot'

module Crystalball
  class MapGenerator
    class FactoryBotStrategy
      # Module to add new patched `factory` method to FactoryBot::Syntax::Default::DSL
      module DSLPatch
        class << self
          # Patches `FactoryBot::Syntax::Default::DSL#factory`. Renames original `factory` to `cb_original_factory` and
          # replaces it with custom one
          def apply!
            ::FactoryBot::Syntax::Default::DSL.class_eval do
              include DSLPatch

              alias_method :cb_original_factory, :factory
              alias_method :factory, :cb_patched_factory
            end
          end

          # Reverts original behavior of `FactoryBot::Syntax::Default::DSL#factory`
          def revert!
            ::FactoryBot::Syntax::Default::DSL.class_eval do
              alias_method :factory, :cb_original_factory # rubocop:disable Lint/DuplicateMethods
              undef_method :cb_patched_factory
            end
          end
        end

        # Will replace original `FactoryBot::Syntax::Default::DSL#factory`. Pushes path of a factory to
        # `FactoryBotStrategy.factory_definitions` and calls original `factory`
        def cb_patched_factory(*args, &block)
          FactoryBotStrategy.factory_definitions[args.first.to_s] = caller(1..1).first.split(':').first

          cb_original_factory(*args, &block)
        end
      end
    end
  end
end
