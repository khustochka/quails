# frozen_string_literal: true

module CommentsHelper
  REAL_NAME_FIELD = -"4e6f280ad67ef127"

  def admin_commenter_id
    @admin_commenter_id ||= Commenter.where(is_admin: true).limit(1).ids.first
  end
end
