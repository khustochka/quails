# frozen_string_literal: true

require "active_support/core_ext/array/inquiry.rb"

module Quails
  class Env
    def initialize
      @raw = ENV["QUAILS_ENV"] || ""
      @arr = @raw.split(":").inquiry
    end

    def nil?
      @raw.nil?
    end

    def inspect
      @raw
    end

    def to_s
      @raw.to_s
    end

    def puma_dev?
      # This is to detect puma-dev. Another way is to puts some env var into .powenv which is only read by puma-dev.
      ENV["PWD"] =~ %r{/.puma-dev/quails\Z}
    end

    def heroku?
      # DYNO is a unique heroku env var (not seen through `heroku config`). You can also mimic it using QUAILS_ENV
      ENV["DYNO"].present? || test_for("heroku")
    end

    def ssl?
      @ssl ||= heroku? || puma_dev? || test_for("ssl")
    end

    def test_for(key)
      @raw && @arr.include?(key)
    end

    def method_missing(method, *args, &block)
      if /^(?<attr>\w+)\?$/ =~ method.to_s
        if @raw
          instance_variable_get("@#{attr}".to_sym) || instance_variable_set("@#{attr}".to_sym, @arr.public_send(method))
        else
          false
        end
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      /^\w+\?$/ =~ method_name.to_s || super
    end
  end
end
