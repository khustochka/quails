class LocusFormatter < ModelFormatter

  def full_name
    format = detect_name_format
    apply_format(format)
  end

  def short_full_name
    format = detect_name_format
    if format =~ /%city/
      format.sub!(/%city(.*)$/, "%city")
    else
      format.sub!(/, %country$/, "")
    end
    apply_format(format)
  end

  private

  def detect_name_format
    @model.name_format.presence || "%self, %country"
  end

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
