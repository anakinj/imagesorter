# frozen_string_literal: true

module Imagesorter
  module Categorizers
    class FileExifCategorizer
      def process(file)
        exif = EXIFR::JPEG.new(file.file)

        exif.to_hash.each do |key, value|
          file["exif.#{key}"] = value
        end

        time = exif.date_time
        return nil if time.nil?

        file.time = time
      rescue StandardError
        nil
      end
    end
  end
end
