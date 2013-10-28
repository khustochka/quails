module Either

  def self.value(value)
    Value.new(value)
  end

  def self.error(msg)
    Error.new(msg)
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

  class Value
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

    def method_missing(method, *args, &block)
      begin
        Value.new(@value.send(method, *args, &block))
      rescue => e
        Error.new(e.message)
      end
    end
  end

  class Error
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
