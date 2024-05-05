# frozen_string_literal: true

namespace :quails do
  namespace :variants do
    desc "Cleanup and recreate image variants"
    task recreate: :environment do
      service = Rails.application.config.active_storage.service
      images = ActiveStorage::Attachment
        .where(name: "stored_image", record_type: "Media")
        .joins(:blob)
        .where(blob: { service_name: service })
        .with_all_variant_records
      images.each do |image|
        Rails.logger.info "[VARIANTS] Destroying variants for #{image.record.slug}"
        image.variant_records.destroy_all
        max_width = image.metadata[:width]
        new_sizes = [640, 900, 1200, 2400]
        new_sizes = new_sizes.select { |size| size == 900 || size <= max_width } if max_width

        Rails.logger.info "[VARIANTS] Creating new variants for #{image.record.slug}: #{new_sizes}"
        new_sizes.each do |width|
          image.blob.preprocessed(ImageRepresenter.resize_and_save_space([width, nil]))
        end
      end
    end
  end
end
