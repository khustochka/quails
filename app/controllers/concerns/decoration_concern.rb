module DecorationConcern
  def decorated(model)
    @decorated_storage = {} unless defined?(@decorated_storage)
    @decorated_storage[model].yield_self do |dec|
      return dec if dec
    end
    decorator_class = case model
                      when Post
                      then
                        NewDecorators::PostDecorator
                      else
                        raise "No decorator for model of class #{model.class.to_s}"
                      end
    decorator_class.new(model, self.view_context, self.decoration_strategy_class)
  end

  def decoration_strategy_class
    NewStrategy::SiteStrategy
  end
end
