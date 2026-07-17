# frozen_string_literal: true

require "test_helper"
require "quails/env"

class EnvTest < ActiveSupport::TestCase
  # QUAILS_ENV is read when Quails::Env is built, but DYNO and PWD are read on every call,
  # so the env object must be used while ENV is still replaced.
  def env_with(quails_env, **other)
    vars = { "QUAILS_ENV" => quails_env, "DYNO" => nil, "PWD" => "/somewhere" }.merge(other)
    saved = ENV.to_hash.slice(*vars.keys)
    vars.each { |key, value| value.nil? ? ENV.delete(key) : ENV[key] = value }
    yield(Quails::Env.new)
  ensure
    vars.each_key { |key| saved.key?(key) ? ENV[key] = saved[key] : ENV.delete(key) }
  end

  test "flags listed in QUAILS_ENV are true" do
    env_with("live:no_hsts") do |env|
      assert_predicate env, :live?
      assert_predicate env, :no_hsts?
    end
  end

  test "flags absent from QUAILS_ENV are false" do
    env_with("live") { |env| assert_not_predicate env, :no_hsts? }
    env_with("") { |env| assert_not_predicate env, :live? }
  end

  test "flag lookup is memoized" do
    env_with("live") do |env|
      assert_predicate env, :live?
      assert_predicate env, :live?
    end
  end

  test "responds to any predicate but not to other methods" do
    env_with("live") do |env|
      assert_respond_to env, :anything?
      assert_not_respond_to env, :anything
      assert_raises(NoMethodError) { env.anything }
    end
  end

  test "to_s and inspect return the raw value" do
    env_with("live:ssl") do |env|
      assert_equal "live:ssl", env.to_s
      assert_equal "live:ssl", env.inspect
    end
  end

  test "test_for checks a flag by name" do
    env_with("live") do |env|
      assert env.test_for("live")
      assert_not env.test_for("heroku")
    end
  end

  test "heroku? is true when DYNO is set" do
    env_with("", "DYNO" => "web.1") { |env| assert_predicate env, :heroku? }
  end

  test "heroku? can be mimicked through QUAILS_ENV" do
    env_with("heroku") { |env| assert_predicate env, :heroku? }
  end

  test "heroku? is false without DYNO and without the flag" do
    env_with("live") { |env| assert_not_predicate env, :heroku? }
  end

  test "puma_dev? detects the puma-dev working directory" do
    env_with("", "PWD" => "/Users/someone/.puma-dev/quails") { |env| assert_predicate env, :puma_dev? }
    env_with("", "PWD" => "/Users/someone/quails") { |env| assert_not_predicate env, :puma_dev? }
  end

  test "ssl? is true on heroku" do
    env_with("", "DYNO" => "web.1") { |env| assert_predicate env, :ssl? }
  end

  test "ssl? is true under puma-dev" do
    env_with("", "PWD" => "/Users/someone/.puma-dev/quails") { |env| assert_predicate env, :ssl? }
  end

  test "ssl? is true with the ssl flag" do
    env_with("ssl") { |env| assert_predicate env, :ssl? }
  end

  test "ssl? is false otherwise" do
    env_with("live") { |env| assert_not_predicate env, :ssl? }
  end
end
