# frozen_string_literal: true

module PublicRoutesHelper
  def localized_images_url(*args)
    if blogless_locale?
      alternative_root_url(*args)
    else
      images_url(*args)
    end
  end
end
