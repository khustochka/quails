# frozen_string_literal: true

require "net/http"

module Birdnik
  # HTTP client for Birdnik, the service that provides external checklists for importing.
  # Birdnik acknowledges requests immediately and pushes results to the given callback URL.
  # See doc/birdnik.md.
  class Client
    class Error < StandardError
    end

    NETWORK_ERRORS = [SystemCallError, SocketError, IOError, Timeout::Error, OpenSSL::SSL::SSLError].freeze

    def initialize(base_url: ENV["BIRDNIK_API_URL"], token: ENV["BIRDNIK_API_TOKEN"])
      raise Error, "BIRDNIK_API_URL is not set." if base_url.blank?

      @base_url = base_url.chomp("/")
      @token = token
    end

    # Asks Birdnik to push unsubmitted checklists to +callback_url+.
    def request_preload(callback_url:)
      post("/preloads", callback_url: callback_url)
    end

    # Asks Birdnik to fetch checklists and push each one to +callback_url+.
    def request_fetch(external_ids:, callback_url:)
      post("/fetches", external_ids: external_ids, callback_url: callback_url)
    end

    private

    def post(path, body)
      uri = URI("#{@base_url}#{path}")
      request = Net::HTTP::Post.new(uri, "Content-Type" => "application/json", "Authorization" => "Bearer #{@token}")
      request.body = body.to_json
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 5, read_timeout: 10) do |http|
        http.request(request)
      end
      raise Error, "Birdnik responded with #{response.code}." unless response.is_a?(Net::HTTPSuccess)

      response
    rescue *NETWORK_ERRORS => e
      raise Error, "Birdnik is unreachable: #{e.message}"
    end
  end
end
