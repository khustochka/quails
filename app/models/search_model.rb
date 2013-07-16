class SearchModel

  # This makes it act as Model usable to build form

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def self.model_name
    ActiveModel::Name.new(self, nil, "Q")
  end

  def persisted?
    false
  end

  def method_missing(method)
    if method.to_s.in?(@attributes)
      @conditions[method]
    else
      super
    end
  end

  # This makes it usable as an Relation

  # TODO: implement respond_to?
  include ActiveRecord::Querying
  delegate :to_a, :to_sql, to: :all
  # Taken from ActiveRecord::Delegation
  delegate :to_xml, :to_yaml, :length, :collect, :map, :each, :all?, :include?, :to_ary, :to => :all

  def ==(other)
    case other
      when ActiveRecord::Relation, SearchModel
        other.to_sql == to_sql
      when Array
        to_a == other
    end
  end

  def all
    @relation ||= @scope.where(normalized_conditions)
  end

  # Initializer

  def initialize(scope, conditions)
    @scope = scope
    @conditions = (conditions || {}).with_indifferent_access
    @attributes = @scope.column_names
  end

  private
  def normalized_conditions
    @normalized_conditions ||= @conditions.reject { |_, v| v != false && v.blank? }
  end

end
