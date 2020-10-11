# frozen_string_literal: true

module ActiveStorage
  class Analyzer
    class ExifDateImageAnalyzer < ImageAnalyzer
        def metadata
          read_image do |image|
            mdata = {}
            exif_date = image.exif["DateTimeOriginal"]
            if exif_date.present?
              mdata[:exif_date] = exif_date.split(":", 3).join("-")
            end
            if rotated_image?(image)
              mdata.merge!({width: image.height, height: image.width})
            else
              mdata.merge!({width: image.width, height: image.height})
            end
            mdata
          end
        rescue LoadError
          logger.info "Skipping image analysis because the mini_magick gem isn't installed"
          {}
        end
    end
  end
end
