# frozen_string_literal: true

module PublicRoutesHelper
  def localized_images_url(*args)
    if default_locale?
      images_url(*args)
    else
      localized_root_url(*args)
    end
  end
end
