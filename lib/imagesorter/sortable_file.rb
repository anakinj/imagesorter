# frozen_string_literal: true

module Imagesorter
  # Base for every sortable entity
  class SortableFile < OpenStruct
    def initialize(path)
      super(file: File.new(path))
    end

    def process!(processor)
      processor.process(self)
    end
  end
end
