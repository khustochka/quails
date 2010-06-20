module ApplicationHelper
  def default_window_caption
    Rails.env == 'development' ? '!!! - Set the window caption / quails3' : request.host
  end
end
