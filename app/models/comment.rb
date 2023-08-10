# frozen_string_literal: true

class Comment < ApplicationRecord
  STOP_WORDS = %w( replica vuitton generic zithromax cheap cialis payday loans pharmacy url=http link=http
    viagra tricor accutane seroquel retin lasix )

  ALLOWED_PARAMETERS = [:body, :parent_id]

  include DecoratedModel

  belongs_to :post, touch: :commented_at
  has_many :subcomments, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent_comment
  belongs_to :parent_comment, class_name: "Comment", foreign_key: :parent_id, inverse_of: :subcomments, optional: true
  belongs_to :commenter, optional: true

  validates :body, :name, presence: true
  validates :parent_id, numericality: true, allow_blank: true

  validate :consistent_post_and_parent

  default_scope { order(:created_at) }

  scope :approved, -> { where(approved: true) }

  scope :unapproved, -> { where(approved: false) }

  scope :top_level, -> { where(parent_id: nil) }

  def like_spam?
    @likespam ||= body.match?(/#{STOP_WORDS.join("|")}/i) ||
      body.scan(/href=/i).size > 4
  end

  def sane_url
    uri = Addressable::URI.heuristic_parse(url)
    if uri&.scheme&.in?(%w[http https])
      uri.to_str
    end
  end

  private

  def consistent_post_and_parent
    if parent_comment && parent_comment.post_id != post_id
      errors.add(:parent_comment, "must belong to the same post")
    end
  end
end
