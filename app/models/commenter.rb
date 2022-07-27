# frozen_string_literal: true

class Commenter < ApplicationRecord
  has_many :comments, dependent: :restrict_with_exception
end
