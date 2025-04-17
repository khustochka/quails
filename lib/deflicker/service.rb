# frozen_string_literal: true

require "flickr/client"

module Deflicker
  class Service
    def load_data
      res = []
      photos = []
      page = 1
      until page > 1 && res.size < 500
        res = load_page(page).to_a
        page += 1
        photos.concat(res)
      end
      store(photos)
    end

    def match_to_site
      my_ids = Flicker.where(removed: false).pluck(:flickr_id)
      images = Image.where.not(external_id: nil)
      site_ids = images.pluck(:external_id)
      raise "Invalid flickr ids in images table: #{site_ids - my_ids}!" if (site_ids - my_ids).any? && !Rails.env.development?

      images.each do |img|
        Flicker.where(flickr_id: img.external_id).first.update(slug: img.slug, on_s3: img.on_storage?)
      end
      # Only clear slugs from not removed images
      unused = Flicker.where(removed: false).pluck(:flickr_id) - site_ids
      Flicker.in(flickr_id: unused).update_all(slug: nil, on_s3: false)
    end

    private

    def flickr_client
      @flickr_client ||= Flickr::Client.new
    end

    def load_page(page)
      flickr_client.photos.search({
        user_id: "me",
        per_page: 500,
        page: page,
        extras: "description, license, date_upload, date_taken, owner_name, icon_server, original_format, last_update, geo, tags, machine_tags, o_dims, views, media, path_alias, url_sq, url_t, url_s, url_q, url_m, url_n, url_z, url_c, url_l, url_o",
      }).get
    end

    def store(photos)
      photos.each do |photo|
        photo1 = photo.to_hash
        flicker = Flicker.find_or_create_by(flickr_id: photo1["id"])
        flicker.update(photo1.except("id").merge(removed: false))
      end
      detect_deleted(photos)
      match_to_site
    end

    def detect_deleted(photos)
      # This is not AR object
      current_ids = photos.map {|p| p["id"]} # rubocop:disable Rails/Pluck
      my_ids = Flicker.pluck(:flickr_id)
      removed_ids = my_ids - current_ids
      Flicker.in(flickr_id: removed_ids).update_all(removed: true)
      # There should not be ids in the API that are not present in the DB
      raise "Inconsistent data" if (current_ids - my_ids).any?
    end
  end
end
