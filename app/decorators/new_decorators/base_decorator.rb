module NewDecorators
  class BaseDecorator
    def initialize(model, context, strategy)
      @model = model
      instance_variable_set(:"@#{self.class::model_name}", model)
      @context = context
      @strategy = strategy.new(context)
    end
  end
end
