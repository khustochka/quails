module Deflicker
  class JournalEntry
    include Mongoid::Document

    field :user, type: String
    field :server, type: String
    field :event, type: String
    field :anum, type: Integer
    field :itemid, type: Integer
    field :subject, type: String
    field :time, type: Time
    field :images, type: Array, default: []
    field :flickr_ids, type: Array, default: []

    def url
      "https://#{user}.#{server}/#{display_itemid}.html"
    end

    def display_itemid
      (itemid << 8) + anum
    end

    def extract_images
      doc = Nokogiri::HTML(event)
      imgs = doc.search("img").map {|el| el.attr(:src)}.uniq
      ids = imgs.select {|url| url =~ /flickr\.com/}.map do |url|
        m = url.match(/flickr\.com\/(?:\d+\/)?\d+\/(\d+)_/)
        m[1]
      end
      update(images: imgs, flickr_ids: ids)
    end
  end
end
