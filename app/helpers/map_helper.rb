# frozen_string_literal: true

module MapHelper
  def map_enabled
    !Rails.env.test?
  end
end
