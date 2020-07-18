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
    field :links, type: Array, default: []
    field :flickr_ids, type: Array, default: []

    has_and_belongs_to_many :flickers

    def url
      "https://#{user}.#{server}/#{display_itemid}.html"
    end

    def display_itemid
      (itemid << 8) + anum
    end

    def extract_images_links
      doc = Nokogiri::HTML(event)
      imgs = doc.search("img").map {|el| el.attr(:src)}.uniq
      ids1 = imgs.select {|url| url =~ /flickr\.com/}.map do |url|
        m = url.match(/flickr\.com\/(?:\d+\/)?\d+\/(\d+)_/)
        m[1]
      end
      links = doc.search("a").map {|el| el.attr(:href)}.uniq
      ids2 = links.select {|url| url =~ /flickr\.com/}.map do |url|
        m = url.match(/flickr\.com\/(?:\d+\/)?\d+\/(\d+)_/) || url.match(/flickr\.com\/photos\/[^\/]*\/(\d+)\/?/)
        m.try(:[], 1)
      end
      ids = (ids1 + ids2.compact).uniq
      update(images: imgs, links: links, flickr_ids: ids)
      ids.each do |fid|
        flicker = Flicker.find_by(flickr_id: fid) rescue nil
        if flicker
          self.flickers << flicker
        else
          puts "Not found: flicker #{fid}, entry #{url}"
        end
      end
      save
    end
  end
end
