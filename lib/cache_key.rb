# frozen_string_literal: true

class CacheKey

  def initialize(topic)
    @topic = topic
  end

  def to_s
    value.to_s
  end

  def value
    Rails.cache.fetch("cache_key/#{@topic}") do
      Time.now.to_i
    end
  end

  def invalidate
    Rails.cache.delete("cache_key/#{@topic}")
  end

  module ClassMethods

    def gallery
      keys[:gallery] ||= new(:gallery)
    end

    def checklist
      keys[:checklist] ||= new(:checklist)
    end

    def lifelist
      keys[:lifelist] ||= new(:lifelist)
    end

    private
    def keys
      @keys ||= {}
    end
  end

  class << self
    include ClassMethods
  end

end
