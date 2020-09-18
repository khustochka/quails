class LocusFormatter < ModelFormatter

  def full_name
    [@model, @model.cached_parent, @model.cached_city, @model.cached_subdivision, @model.cached_country].
        compact.uniq.map(&:name).join(", ")
  end

  def short_full_name
    [@model, @model.cached_parent, @model.cached_city, @model.cached_subdivision].
        compact.uniq.map(&:name).join(", ")
  end

  private

  def apply_format(format)
    pre_ancestors = @model.ancestors
    ancestors = pre_ancestors.index_by(&:loc_type)
    ancestors['self'] = @model
    ancestors['parent'] = pre_ancestors.last

    format.gsub(/%(\w+)/) do
      ancestors[$1].try(:name)
    end
  end

end
