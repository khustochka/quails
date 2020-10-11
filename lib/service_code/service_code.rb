# frozen_string_literal: true

class ServiceCode
  include ActiveSupport::Configurable

  def self.render(view)
    new(view).render
  end

  def self.configure
    config.code = ENV[self::CODE_ENV_VAR]
  end

  def self.configured?
    config.code
  end

  def configured?
    self.class.configured?
  end

  def initialize(view)
    @view = view
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

  def may_be_admin?
    @view.has_trust_cookie? || @view.admin_layout?
  end

  def is_admin?
    @view.current_user.admin?
  end

end
