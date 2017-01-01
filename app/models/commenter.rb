class Commenter < ApplicationRecord
  has_many :comments

  serialize :auth_hash, HashWithIndifferentAccess
end
