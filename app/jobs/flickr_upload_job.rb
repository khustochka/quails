class FlickrUploadJob < ApplicationJob
  queue_as :default

  def perform(image, options = {})
    FlickrUpload.new(image, options).perform
  end
end
