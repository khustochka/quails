module CommentsHelper

  REAL_NAME_FIELD = -"3e6f2809d67ef117"

  def admin_commenter_id
    @admin_commenter_id ||= Commenter.where(is_admin: true).pluck(:id).first
  end
end
