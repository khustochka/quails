# frozen_string_literal: true

require "test_helper"

class ClearCacheJobTest < ActiveJob::TestCase
  test "clears the cache" do
    original = Rails.cache
    Rails.cache = ActiveSupport::Cache::MemoryStore.new
    Rails.cache.write("some/key", "value")

    ClearCacheJob.perform_now

    assert_nil Rails.cache.read("some/key")
  ensure
    Rails.cache = original
  end

  test "runs on the default queue" do
    assert_equal "default", ClearCacheJob.new.queue_name
  end
end
