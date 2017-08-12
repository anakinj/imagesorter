# frozen_string_literal: true

module Imagesorter
  module Categorizers
    class FileStatCategorizer
      def initialize(stat)
        @stat = stat
      end

      def process(file)
        time = file.file.send(@stat)
        return nil if time.nil?
        file.time = time
      end
    end
  end
end
