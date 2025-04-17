# frozen_string_literal: true

module Deflicker
  class EntryFix
    attr_reader :body

    def initialize(entry, passwd)
      @entry = entry
      @passwd = passwd
      @body = fetch_body
    end

    def fetch_body
      user = build_user

      req = LiveJournal::Request::GetEvents.new(user, itemid: @entry.itemid)
      res = req.run

      res.event
    end

    def new_body
      @new_body ||= build_new_body
    end

    def build_new_body
      doc = Nokogiri::HTML::DocumentFragment.parse(body)
      srcs = doc.search("img").map { |el| el.attr(:src) }.uniq.grep(/flickr\.com/)
      src_arr = srcs.map do |src|
        m = src.match(%r{flickr\.com/(?:\d+/)?\d+/(\d+)_})
        [src, Image.find_by(external_id: m[1])]
      end
      src_map = Hash[src_arr]

      src_map.each do |src, image|
        if image
          img_tag = doc.search("img[src='#{src}']").first
          img_tag["src"] = "https://birdwatch.org.ua/photos/#{image.slug}.jpg"
        end
      end

      # hrefs = doc.search("a").map { |el| el.attr(:href) }.uniq.grep(/flickr\.com/)
      # href_arr = hrefs.map do |href|
      #   m = url.match(%r{flickr\.com/(?:\d+/)?\d+/(\d+)_}) || url.match(%r{flickr\.com/photos/[^/]*/(\d+)/?})
      #   found = m&.slice(1)
      #   image = if found
      #     Image.find_by(external_id: found)
      #   end
      #   [href, image]
      # end
      # href_map = Hash[href_arr]

      # href_map.each do |href, image|
      #   if image
      #     a_tag = doc.search("a[href='#{href}']").first
      #     a_tag["src"] = "https://birdwatch.org.ua/photos/#{image.slug}.jpg"
      #   end
      # end

      doc.to_html
    end

    private

    def build_user
      server = LiveJournal::Server.new(@entry.server, "https://#{@entry.server}")
      u = @entry.user
      journal = @entry.journal

      user = LiveJournal::User.new(u, @passwd, server)
      user.usejournal = journal

      user
    end
  end
end
