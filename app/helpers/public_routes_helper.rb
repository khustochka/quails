module PublicRoutesHelper
  delegate :url_helpers, to: 'Rails.application.routes'

  def public_post_path(post, options = {})
    url_helpers.show_post_path(post.to_url_params.merge(options))
  end

  def public_comment_path(comment, post = nil)
    post ||= comment.post
    public_post_path(post, :anchor => "comment#{comment.id}")
  end
end
