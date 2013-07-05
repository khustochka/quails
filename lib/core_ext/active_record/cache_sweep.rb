class ActiveRecord::Base

  def self.invalidates(cache_key)
    self.after_save { cache_key.invalidate }
    self.after_destroy { cache_key.invalidate }
  end

end
