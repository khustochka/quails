module Either

  def self.value(value)
    VALUE_CLASS.new(value)
  end

  def self.error(msg)
    ERROR_CLASS.new(msg)
  end

  def self.sequence(*args)
    args.inject do |memo, obj|
      if obj.error?
        return obj
      else
        memo.concat(obj.get)
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
