module Quails

  class Env < String
    def self.init
      new(ENV['QUAILS_ENV'] || '')
    end

    def initialize(val)
      @raw = val
      @arr = val.split(':')
      super
    end

    def method_missing(method, *args, &block)
      if /^(?<attr>.*)\?$/ =~ method.to_s
        @arr.include?(attr)
      else
        #super
      end
    end
  end

  def self.env
    @raw_str ||= Env.init
  end
end
