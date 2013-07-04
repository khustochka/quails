class ActiveRecord::Base

  def self.sweep_cache(symbol)
    case symbol
      when :gallery
      then
        self.after_save { $gallery_cache_key = nil }
        self.after_destroy { $gallery_cache_key = nil }
    end
  end

end
