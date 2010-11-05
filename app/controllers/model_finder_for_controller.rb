module ModelFinderForController

  def add_finder_by(*args)
    options = args.extract_options!
    before_filter options do
      value = controller_name.classify.constantize.send("find_by_#{args[0]}!", params[:id])
      instance_variable_set("@#{controller_name.singularize}".to_sym, value)
    end
  end

end