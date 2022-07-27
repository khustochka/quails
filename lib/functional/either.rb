# frozen_string_literal: true

module Either
  def self.included(klass)
    class << klass
      def value(value)
        self::VALUE_CLASS.new(value)
      end

      def error(msg)
        self::ERROR_CLASS.new(msg)
      end
    end
  end

  module Value
    class Applicator
      def initialize(obj)
        @obj = obj
      end

      def method_missing(method, *args, &block)
        arg = args.first
        if arg.error?
          arg
        else
          @obj.class.new(@obj.get.public_send(method, arg.get))
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        true
      end
    end

    def initialize(value)
      @value = value
    end

    def valid?
      true
    end

    def error?
      false
    end

    def get
      @value
    end

    def apply
      self.class::Applicator.new(self)
    end
  end

  module Error
    attr_reader :errors

    class Applicator
      def initialize(obj)
        @obj = obj
      end

      def method_missing(method, *args, &block)
        @obj
      end

      def respond_to_missing?(method_name, include_private = false)
        true
      end
    end

    class EitherErrorException < StandardError
    end

    def initialize(msg)
      @msg = msg
      @errors = ActiveModel::Errors.new(self)
      @errors.add(:base, msg)
    end

    def error?
      true
    end

    def valid?
      false
    end

    def get
      raise EitherErrorException, @msg
    end

    def method_missing(method, *args, &block)
      self
    end

    def respond_to_missing?(method_name, include_private = false)
      true
    end

    def apply
      self.class::Applicator.new(self)
    end
  end
end
