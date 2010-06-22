module AdminPanelHelper
  def new_path_helper
    url_for({:action => :new})
  end

  def show_path_helper(obj)
    url_for({:action => :show, :id => obj})
  end

  def edit_path_helper(obj)
    url_for({:action => :edit, :id => obj})
  end

  def destroy_path_helper(obj)
    url_for({:action => :destroy, :id => obj})
  end

  def index_path_helper
    url_for({:action => :index})
  end
end