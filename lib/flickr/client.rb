# frozen_string_literal: true

require "functional/either"
require "flickraw-cached"

module Flickr
  include Functional::Either

  module ResultPartialPath
    def to_partial_path
      "flickr_photos/result"
    end
  end

  class Result
    include Functional::Either::Value
    include ResultPartialPath

    def method_missing(method, *args, &block) # rubocop:disable Style/MissingRespondToMissing
      Result.new(@value.public_send(method, *args, &block))
    rescue FlickRaw::Error => e
      Error.new(e.message)
    end

    def search_and_filter_photos(conditions, top = nil, &filter)
      all = Flickr::Result.new([])
      page = 0
      loop do
        set = search_and_get_page(conditions, page += 1)
        filtered_result = yield(set)
        all = all.apply.concat(filtered_result)
        break if all.error? || set.get.size < 500 || (top && all.get.size >= top)
      end
      result = all
      if top
        result = all.take(top)
      end
      result
    end

    def search_and_get_page(conditions, page)
      call(
        "flickr.photos.search",
        conditions.merge(page: page, per_page: 500)
      )
    end
  end

  class Error
    include Functional::Either::Error
    include ResultPartialPath
  end

  Flickr::VALUE_CLASS = Result
  Flickr::ERROR_CLASS = Error

  class << Flickr
    __send__(:alias_method, :result, :value)
  end

  class Client
    def self.new
      if FlickRaw.configured?
        client = FlickRaw::Flickr.new
        admin = Settings.flickr_admin
        client.access_token = admin.access_token
        client.access_secret = admin.access_secret
        Flickr.result(client)
      else
        Flickr.error("No Flickr API key or secret defined!")
      end
    end
  end
end
