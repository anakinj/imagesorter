# frozen_string_literal: true

module Imagesorter
  module Categorizers
    # Chains categorizers together, will try in order until gets a successfull result
    class ChainedCategorizer
      def initialize(*categorizers)
        @categorizers = categorizers
      end

      def process(file)
        result = nil
        @categorizers.each do |categorizer|
          result = categorizer.process(file)
          return result unless result.nil?
        end
      end

      def step_name
        'Categorizing'
      end
    end
  end
end
