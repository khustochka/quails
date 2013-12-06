module Quails

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

    def ssl?
      @ssl ||= real_prod? || heroku? || (@raw && @arr.include?('ssl'))
    end

    def method_missing(method, *args, &block)
      if @raw && /^(?<attr>.*)\?$/ =~ method.to_s
        instance_variable_get("@#{attr}".to_sym) || instance_variable_set("@#{attr}".to_sym, @arr.include?(attr))
      else
        #super
      end
    end
  end

  def self.env
    @env ||= Env.init
  end
end
