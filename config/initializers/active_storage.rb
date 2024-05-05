# frozen_string_literal: true

require "quails/exif_date_image_analyzer"

Rails.application.configure do
  config.active_storage.analyzers = [Quails::ExifDateImageAnalyzer]
  config.active_storage.service_urls_expire_in = 30.days
  config.active_storage.queues.analysis = :storage
  config.active_storage.queues.mirror = :storage
  config.active_storage.queues.transform = :storage
  config.active_storage.queues.purge = :storage
end
