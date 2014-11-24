class LocusFormatter < ModelFormatter

  def full_name
    format = @model.name_format
    format = "%self, %country" if format.blank?

    ancestors = @model.ancestors.index_by(&:loc_type)
    ancestors['self'] = @model

    format.gsub(/%(\w+)/) do
      ancestors[$1].try(:name)
    end
  end

end
