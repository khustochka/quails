module ModelFinderForController

  def add_finder_by(*args)
    options = args.extract_options!
    before_filter options do
      instance_variable_set(
          "@#{controller_name.singularize}".to_sym,
          controller_name.classify.constantize.send("find_by_#{args[0]}!", params[:id])
      )
    end
  end

end