class ActiveRecord::Base

  def self.sweep_cache(symbol)
    case symbol
      when :gallery
      then
        self.after_save { $gallery_cache_key = nil }
        self.after_destroy { $gallery_cache_key = nil }
      when :checklist
      then
        self.after_save { $checklist_cache_key = nil }
        self.after_destroy { $checklist_cache_key = nil }
      when :lifelist
      then
        self.after_save { $lifelist_cache_key = nil }
        self.after_destroy { $lifelist_cache_key = nil }
    end
  end

end
