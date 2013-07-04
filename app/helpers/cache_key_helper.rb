module CacheKeyHelper

  def gallery_cache_key
    $gallery_cache_key ||= Time.now.to_i
  end

  def checklist_cache_key
    $checklist_cache_key ||= Time.now.to_i
  end

end
