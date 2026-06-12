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

      images_sql = Image.select("media.*", observation_ids)
        .order(:id)
        .page(params[:page])
        .per(params[:per_page] || DEFAULT_PER_PAGE)
      images = ActiveRecord::Base.connection.select_all(images_sql)

      # select_all bypasses type casting, so the json_agg column arrives as a
      # JSON string. Decode it back into an array of observation ids.
      obs_idx = images.columns.index("observation_ids")
      rows = images.rows.each do |row|
        row[obs_idx] = row[obs_idx] ? JSON.parse(row[obs_idx]) : []
      end

      respond_to do |format|
        format.json {
          render json: { columns: images.columns, rows: rows }
        }
      end
    end
  end
end
