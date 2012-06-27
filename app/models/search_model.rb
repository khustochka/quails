class SearchModel

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def self.model_name
    ActiveModel::Name.new(self, nil, "Q")
  end

  def persisted?
    false
  end

  def initialize(scope, conditions)
    @scope = scope
    @conditions = (conditions || {}).with_indifferent_access
    @attributes = @scope.column_names
  end

  def result
    @relation ||= @scope.where(normalized_conditions)
  end

  def method_missing(method)
    if method.to_s.in?(@attributes)
      @conditions[method]
    else
      super
    end
  end

  private
  def normalized_conditions
    @normalized_conditions ||= @conditions.reject { |_, v| v != false && v.blank? }
  end

end
