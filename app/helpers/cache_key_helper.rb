module CacheKeyHelper

  def gallery_cache_key
    $gallery_cache_key ||= Time.now.to_i
  end

end
