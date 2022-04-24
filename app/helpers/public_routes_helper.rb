# frozen_string_literal: true

module PublicRoutesHelper
  def localized_images_url(*args)
    unless blogless_locale?
      images_url(*args)
    else
      alternative_root_url(*args)
    end
  end
end
