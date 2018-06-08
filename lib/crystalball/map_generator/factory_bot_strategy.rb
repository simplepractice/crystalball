# frozen_string_literal: true

require 'crystalball/map_generator/base_strategy'
require 'crystalball/map_generator/helpers/path_filter'
require 'crystalball/map_generator/factory_bot_strategy/dsl_patch'
require 'crystalball/map_generator/factory_bot_strategy/factory_runner_patch'

module Crystalball
  class MapGenerator
    # Map generator strategy to include list of strategies which was used in an example.
    class FactoryBotStrategy
      include ::Crystalball::MapGenerator::BaseStrategy
      include ::Crystalball::MapGenerator::Helpers::PathFilter

      class << self
        # List of factories used by current example
        #
        # @return [Array<String>]
        attr_reader :used_factories

        # Map of factories to files
        #
        # @return [Hash<String, String>]
        attr_reader :factory_definitions

        # Reset cached list of factories
        def reset_used_factories
          @used_factories = []
        end

        # Reset map of factories to files
        def reset_factory_definitions
          @factory_definitions = {}
        end
      end

      def after_start
        self.class.reset_factory_definitions
        DSLPatch.apply!
        FactoryRunnerPatch.apply!
      end

      def before_finalize
        DSLPatch.revert!
        FactoryRunnerPatch.revert!
      end

      # Adds factories related to the spec to the case map
      # @param [Crystalball::CaseMap] case_map - object holding example metadata and affected files
      def call(case_map, _)
        self.class.reset_used_factories
        yield case_map
        case_map.push(*filter(self.class.used_factories))
      end
    end
  end
end
