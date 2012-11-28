module RecordFinder

  def find_record(options = {})
    only = options[:before]
    raise ArgumentError, "Please define actions explicitly for record finder" unless only
    column = options[:by] || :id
    before_filter only: only do
      instance_variable_set(
          "@#{controller_name.singularize}".to_sym,
          controller_name.classify.constantize.send("find_by_#{column}!", params[:id])
      )
    end
  end

end
