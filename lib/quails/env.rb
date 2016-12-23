module Quails

  CURRENT_YEAR = 2016

  class Env
    def self.init
      new(ENV['QUAILS_ENV'])
    end

    def initialize(val)
      @raw = val
      @arr = val.split(':') if @raw
    end

    def rake?
      defined?(Rake)
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
      ENV["PUMADEV_ENV"]
    end

    def ssl?
      @ssl ||= real_prod? || heroku? || puma_dev? || (@raw && @arr.include?('ssl'))
    end

    def method_missing(method, *args, &block)
      if /^(?<attr>.*)\?$/ =~ method.to_s
        if @raw
          instance_variable_get("@#{attr}".to_sym) || instance_variable_set("@#{attr}".to_sym, @arr.include?(attr))
        else
          false
        end
      else
        super
      end
    end

    def respond_to?(method)
      if /^.*\?$/ =~ method.to_s
        true
      else
        super
      end
    end
  end

  def self.env
    @env ||= Env.init
  end
end
