# frozen_string_literal: true

module PublicRoutesHelper

  private
  def localize_url(string_or_obj, opts = {})
    new_args = opts.merge({id: string_or_obj})
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

  def localize_path(string_or_obj, opts = {})
    localize_url(string_or_obj, opts.merge(only_path: true))
  end

end
