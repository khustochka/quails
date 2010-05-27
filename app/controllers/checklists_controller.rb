class ChecklistsController < PublicController

  def index
    render :text => Date.today.strftime("%A, %-d %B %Y") + Time.zone.now.strftime(" %X (%Z)")
  end

end