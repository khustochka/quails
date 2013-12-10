module CommentsHelper
  def admin_commenter_id
    @admin_commenter_id ||= Commenter.where(is_admin: true).pluck(:id).first
  end
end
