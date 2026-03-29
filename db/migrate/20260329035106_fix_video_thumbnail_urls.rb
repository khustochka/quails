class FixVideoThumbnailUrls < ActiveRecord::Migration[8.1]
  def up
    execute <<-SQL
      UPDATE media
      SET assets_cache = REPLACE(assets_cache, ',//img.youtube.com/', ',https://img.youtube.com/')
      WHERE media_type = 'video'
        AND assets_cache LIKE '%,//img.youtube.com/%'
    SQL
  end

  def down
    # No-op: reverting to protocol-relative URLs is not desired
  end
end
