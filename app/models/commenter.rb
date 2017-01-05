class Commenter < ApplicationRecord
  has_many :comments

  serialize :auth_hash, HashWithIndifferentAccess

  def admin?
    provider == "admin"
  end
end
