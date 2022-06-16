# frozen_string_literal: true

require "core_ext/active_storage/exif_date_image_analyzer"

Rails.application.config.active_storage.analyzers = [ActiveStorage::Analyzer::ExifDateImageAnalyzer]
Rails.application.config.active_storage.service_urls_expire_in = 30.days
Rails.application.config.active_storage.queues.purge = :storage_low_priority
Rails.application.config.active_storage.queues.mirror = :storage_low_priority
