module PathsHelper
  def new_path_helper
    url_for({:action => :new})
  end

  def show_path_helper(obj = nil)
    url_for({:action => :show, :id => obj || instance_variable_get("@#{controller_name.singularize}".to_sym)})
  end

  def edit_path_helper(obj = nil)
    url_for({:action => :edit, :id => obj || instance_variable_get("@#{controller_name.singularize}".to_sym)})
  end

  def destroy_path_helper(obj = nil)
    url_for({:action => :destroy, :id => obj || instance_variable_get("@#{controller_name.singularize}".to_sym)})
  end

  def index_path_helper(options = {})
    url_for(options.merge(:action => :index))
  end

  def blog_path
    root_path
  end
end