# frozen_string_literal: true

module PublicRoutesHelper

  def localized_images_url(*args)
    if I18n.default_locale?
      images_url(*args)
    else
      localized_root_url(*args)
    end
  end

  private
  def localize_url(string_or_obj, args = {})
    new_args = args.merge({id: string_or_obj})
    case string_or_obj
    when Image
        localized_image_url(new_args)
    when Video
        localized_video_url(new_args)
    when Species
        localized_species_url(new_args)
      else
        string_or_obj
    end
  end

end
