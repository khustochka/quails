module PublicRoutesHelper

  def public_post_path(post, options = {})
    show_post_path(post.to_url_params.merge(options))
  end

  def public_post_url(post, options = {})
    show_post_url(post.to_url_params.merge(options))
  end

  def public_comment_path(comment, post = nil)
    post ||= comment.post
    public_post_path(post, :anchor => "comment#{comment.id}")
  end

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
