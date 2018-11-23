class FlickrUploadJob < ApplicationJob
  queue_as :default

  def perform(image)
    FlickrUpload.new(image).perform
  end
end
