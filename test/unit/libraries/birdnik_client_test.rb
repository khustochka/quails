# frozen_string_literal: true

require "test_helper"

class BirdnikClientTest < ActiveSupport::TestCase
  CALLBACK = "http://quails.test/api/external_checklists"

  def client
    Birdnik::Client.new(base_url: "http://birdnik.test/", token: "secret")
  end

  test "requests preload with callback url and bearer token" do
    stub = stub_request(:post, "http://birdnik.test/preloads")
      .with(body: { callback_url: CALLBACK }.to_json, headers: { "Authorization" => "Bearer secret", "Content-Type" => "application/json" })
      .to_return(status: 202)

    client.request_preload(callback_url: CALLBACK)

    assert_requested stub
  end

  test "requests fetch of checklists" do
    stub = stub_request(:post, "http://birdnik.test/fetches")
      .with(body: { external_ids: %w(S1 S2), callback_url: CALLBACK }.to_json, headers: { "Authorization" => "Bearer secret" })
      .to_return(status: 202)

    client.request_fetch(external_ids: %w(S1 S2), callback_url: CALLBACK)

    assert_requested stub
  end

  test "raises on error response" do
    stub_request(:post, "http://birdnik.test/preloads").to_return(status: 500)

    error = assert_raises(Birdnik::Client::Error) { client.request_preload(callback_url: CALLBACK) }
    assert_equal "Birdnik responded with 500.", error.message
  end

  test "raises when Birdnik is unreachable" do
    stub_request(:post, "http://birdnik.test/preloads").to_raise(Errno::ECONNREFUSED)

    assert_raises(Birdnik::Client::Error) { client.request_preload(callback_url: CALLBACK) }
  end

  test "raises when url is not configured" do
    assert_raises(Birdnik::Client::Error) { Birdnik::Client.new(base_url: nil) }
  end
end
