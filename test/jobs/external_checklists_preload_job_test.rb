# frozen_string_literal: true

require "test_helper"

class ExternalChecklistsPreloadJobTest < ActiveJob::TestCase
  setup do
    @original_url = ENV["BIRDNIK_API_URL"]
    ENV["BIRDNIK_API_URL"] = "http://birdnik.test"
  end

  teardown do
    ENV["BIRDNIK_API_URL"] = @original_url
    ENV.delete("BIRDNIK_CALLBACK_HOST")
  end

  test "requests preload with API callback url on the configured host" do
    ENV["BIRDNIK_CALLBACK_HOST"] = "https://quails.test"
    stub = stub_request(:post, "http://birdnik.test/preloads")
      .with(body: { callback_url: "https://quails.test/api/external_checklists" }.to_json).to_return(status: 202)

    ExternalChecklistsPreloadJob.perform_now

    assert_requested stub
  end

  test "fails without callback host" do
    assert_raises(Birdnik::Client::Error) { ExternalChecklistsPreloadJob.perform_now }
  end

  test "fails when Birdnik rejects the request" do
    stub_request(:post, "http://birdnik.test/preloads").to_return(status: 503)

    assert_raises(Birdnik::Client::Error) { ExternalChecklistsPreloadJob.perform_now("https://quails.test") }
  end
end
