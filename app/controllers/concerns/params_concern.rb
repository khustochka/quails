# frozen_string_literal: true

module ParamsConcern
  def self.included(klass)
    klass.helper_method :significant_params, :amended_params
  end

  private

  def allow_params(*list)
    @allowed_params = list + [:action, :controller]
  end

  def significant_params
    if @allowed_params
      params.permit(*@allowed_params)
    else
      {}
    end
  end

  def amended_params(overrides = {})
    significant_params.stringify_keys.merge(overrides.stringify_keys)
  end
end
