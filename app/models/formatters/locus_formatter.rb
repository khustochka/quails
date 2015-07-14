class LocusFormatter < ModelFormatter

  def full_name
    format = @model.name_format
    format = "%self, %country" if format.blank?

    pre_ancestors = @model.ancestors
    ancestors = pre_ancestors.index_by(&:loc_type)
    ancestors['self'] = @model
    ancestors['parent'] = pre_ancestors.last

    format.gsub(/%(\w+)/) do
      ancestors[$1].try(:name)
    end
  end

end
