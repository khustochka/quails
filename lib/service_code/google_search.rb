class GoogleSearch

  def self.render(view)
    new(view).render
  end

  def self.configure(code)
    @@code = code
  end

  def initialize(view)
    @view = view
  end

  def render
    cache [:google_cse, admin: @view.admin_layout?] do
      unless Rails.env.test? || @view.admin_layout? || @@code.blank?
        @view.render partial: 'partials/search', object: @@code, as: :code
      end
    end
  end

  private

  def cache(name = {}, options = nil, &block)
    if @view.controller.perform_caching
      fragment_for(name, options, &block).html_safe
    else
      yield
    end
  end

  def fragment_for(name = {}, options = nil, &block)
    if fragment = @view.controller.read_fragment(name, options)
      fragment
    else
      fragment = block.call || ""
      @view.controller.write_fragment(name, fragment, options)
    end
  end
end
