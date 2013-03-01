class GoogleSearch

  def self.render(view)
    unless Rails.env.test? || view.admin_layout?
      view.render partial: 'partials/search'
    end
  end

end
