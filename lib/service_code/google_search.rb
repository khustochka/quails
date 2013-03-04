module GoogleSearch

  def self.render(view)
    cache view, [:google_cse, admin: view.admin_layout?] do
      unless Rails.env.test? || view.admin_layout? || @code.blank?
        view.render partial: 'partials/search', object: @code, as: :code
      end
    end
  end

  def self.configure(code)
    @code = code
  end

  private
  def self.cache(view, name = {}, options = nil, &block)
    if view.controller.perform_caching
      fragment_for(view, name, options, &block).html_safe
    else
      yield
    end
  end

  def self.fragment_for(view, name = {}, options = nil, &block)
    if fragment = view.controller.read_fragment(name, options)
      fragment
    else
      fragment = block.call || ""
      view.controller.write_fragment(name, fragment, options)
    end
  end
end
