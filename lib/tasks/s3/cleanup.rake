# frozen_string_literal: true

include ActionView::Helpers::NumberHelper

namespace :s3 do
  desc "Find and cleanup unused S3 objects"
  task cleanup: :environment do
    service = ActiveStorage::Blob.services.fetch(:amazon)

    bucket = service.bucket

    blob_used_keys = ActiveStorage::Blob.pluck(:key)

    all_objects = Hash[bucket.objects.map {|obj| [obj.key, obj.size]}]

    all_object_keys = all_objects.keys

    blobs_with_no_s3 = blob_used_keys - all_object_keys

    if blobs_with_no_s3.any?
      puts "\n\nWARNING! These blobs do not have keys in S3:\n"
      puts blobs_with_no_s3
    end

    s3_objects_with_no_blobs = all_object_keys - blob_used_keys

    if s3_objects_with_no_blobs.any?
      puts "\n\nWARNING: S3 object without blobs (total: #{s3_objects_with_no_blobs.size})\n"
      s3_objects_with_no_blobs.each do |key|
        puts "#{key} #{service.url(key)}"
      end

      wasted_storage = s3_objects_with_no_blobs.sum {|k| all_objects[k]}

      puts "\n\nTotal storage of unused objects: #{number_with_delimiter(wasted_storage, delimeter: ",")} bytes\n"

      puts "\n\nDANGER ZONE! Do you want to delete some of these object? Type:"
      puts "* Enter - do not delete"
      puts "* <key> - delete specific object"
      puts "* --all - delete all!"

      puts "\nEnter your choice:"
      user_input = $stdin.gets

      case user_input.chomp
      when ""

      when "--all"
        s3_objects_with_no_blobs.each {|key| service.delete(key) }

      else
        service.delete(user_input.chomp)

      end

    else
      puts "\n\nSUCCESS! There are no orphan S3 objects\n"
    end
  end
end
