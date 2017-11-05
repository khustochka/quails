module Either

  def Either.included(klass)

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
  end

  module Error
    attr_reader :errors

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
      raise @msg
    end

    def method_missing(method, *args, &block)
      self
    end

  end

end
