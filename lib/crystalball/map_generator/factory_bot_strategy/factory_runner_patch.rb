# frozen_string_literal: true

require 'factory_bot'

module Crystalball
  class MapGenerator
    class FactoryBotStrategy
      # Module to add new patched `run` method to FactoryBot::FactoryRunner
      module FactoryRunnerPatch
        class << self
          # Patches `FactoryBot::FactoryRunner#run`. Renames original `run` to `cb_original_run` and
          # replaces it with custom one
          def apply!
            ::FactoryBot::FactoryRunner.class_eval do
              include FactoryRunnerPatch

              alias_method :cb_original_run, :run
              alias_method :run, :cb_patched_run
            end
          end

          # Reverts original behavior of `FactoryBot::FactoryRunner#run`
          def revert!
            ::FactoryBot::FactoryRunner.class_eval do
              alias_method :run, :cb_original_run # rubocop:disable Lint/DuplicateMethods
              undef_method :cb_patched_run
            end
          end
        end

        # Will replace original `FactoryBot::FactoryRunner#run`. Pushes path of a factory to
        # `FactoryBotStrategy.factories` and calls original `run`
        def cb_patched_run(*args)
          FactoryBotStrategy.used_factories.push FactoryBotStrategy.factory_definitions[@name.to_s]
          cb_original_run(*args)
        end
      end
    end
  end
end
