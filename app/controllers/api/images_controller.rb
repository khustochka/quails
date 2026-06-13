# frozen_string_literal: true

module API
  class ImagesController < APIController
    DEFAULT_PER_PAGE = 1000

    def index
      observation_ids = <<~SQL.squish
        (SELECT json_agg(mo.observation_id ORDER BY mo.observation_id)
         FROM media_observations mo
         WHERE mo.media_id = media.id) AS observation_ids
      SQL

      # Pull the stored_image blob in the same query so the original URL and
      # metadata of storage-hosted images can be built without an N+1.
      blob_columns = <<~SQL.squish
        blobs.key AS blob_key,
        blobs.filename AS blob_filename,
        blobs.content_type AS blob_content_type,
        blobs.service_name AS blob_service_name,
        blobs.metadata AS blob_metadata
      SQL

      images_sql = Image.unscoped.where(media_type: "photo")
        .select("media.*", observation_ids, blob_columns)
        .joins(<<~SQL.squish)
          LEFT JOIN active_storage_attachments att
            ON att.record_type = #{Image.connection.quote(Image.base_class.name)}
            AND att.record_id = media.id AND att.name = 'stored_image'
          LEFT JOIN active_storage_blobs blobs ON blobs.id = att.blob_id
        SQL
        .order(:id)
        .page(params[:page])
        .per(params[:per_page] || DEFAULT_PER_PAGE)
      images = ActiveRecord::Base.connection.select_all(images_sql)

      idx = images.columns.each_with_index.to_h
      obs_idx = idx["observation_ids"]

      # The blob_* columns are joined only to derive original_url and meta; keep
      # them out of the response and append those two as the extra columns.
      blob_cols = idx.keys.grep(/\Ablob_/)
      output_idx = images.columns.each_index.reject { |i| blob_cols.include?(images.columns[i]) }

      rows = images.rows.map do |row|
        # select_all bypasses type casting, so the json_agg column arrives as a
        # JSON string. Decode it back into an array of observation ids.
        row[obs_idx] = row[obs_idx] ? JSON.parse(row[obs_idx]) : []
        output_idx.map { |i| row[i] }.push(original_url(row, idx), meta(row, idx))
      end
      columns = output_idx.map { |i| images.columns[i] }.push("original_url", "meta")

      respond_to do |format|
        format.json {
          render json: { columns: columns, rows: rows }
        }
      end
    end

    private

    # Builds the URL of the original (full-size) image asset.
    #   - storage: a public/permanent URL for the stored_image blob, generated
    #     from the columns already joined into the row (no extra query).
    #   - flickr / legacy local: the largest asset in the serialized cache.
    #
    # In the current DB every photo image is stored (has a stored_image blob),
    # so the assets_cache branch is never actually hit; it is kept just in case
    # an unstored image ever appears again.
    def original_url(row, idx)
      if row[idx["blob_key"]]
        blob = ActiveStorage::Blob.new(
          key: row[idx["blob_key"]],
          filename: row[idx["blob_filename"]],
          content_type: row[idx["blob_content_type"]],
          service_name: row[idx["blob_service_name"]]
        )
        blob.url
      else
        original_asset(row, idx)&.full_url
      end
    end

    # Metadata of the original image, omitting keys that are unavailable.
    #   - storage: width / height / exif_date from blob metadata, plus content_type.
    #   - flickr / legacy local: width / height from the largest cached asset.
    def meta(row, idx)
      if row[idx["blob_key"]]
        metadata = row[idx["blob_metadata"]] ? JSON.parse(row[idx["blob_metadata"]]) : {}
        {
          width: metadata["width"],
          height: metadata["height"],
          content_type: row[idx["blob_content_type"]],
          exif_date: metadata["exif_date"],
        }
      else
        original = original_asset(row, idx)
        # Read the raw struct values, not the width/height accessors, which
        # substitute dummy 600x400 dimensions when the real size is unknown.
        { width: original&.[](:width), height: original&.[](:height) }
      end.compact
    end

    # The largest non-storage asset (flickr externals, else legacy locals).
    def original_asset(row, idx)
      assets = ImageAssetsArray.load(row[idx["assets_cache"]]) || ImageAssetsArray.new
      externals = assets.externals
      externals.any? ? externals.original : assets.locals.original
    end
  end
end
