class Comment < ApplicationRecord

  STOP_WORDS = %w( replica vuitton generic zithromax cheap cialis payday loans pharmacy url=http link=http
                    viagra tricor accutane seroquel retin lasix )

  ALLOWED_PARAMETERS = [:text, :parent_id]

  include DecoratedModel

  validates :text, :name, :post_id, :presence => true

  # Parent comment is marked as optional, because there is no comment with id = 0.
  # But parent_id is not optional.
  validates :parent_id, :presence => true

  validate :consistent_post_and_parent

  belongs_to :post, touch: :commented_at
  has_many :subcomments, class_name: 'Comment', foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent_comment
  belongs_to :parent_comment, class_name: 'Comment', foreign_key: :parent_id, inverse_of: :subcomments, optional: true
  belongs_to :commenter, optional: true

  default_scope { order(:created_at) }

  scope :approved, lambda { where(approved: true) }

  scope :unapproved, lambda { where(approved: false) }

  def like_spam?
    @likespam ||= self.text =~ /#{STOP_WORDS.join('|')}/i ||
        self.text.scan(/href=/i).size > 4
  end

  def sane_url
    uri = Addressable::URI.heuristic_parse(url)
    if uri && uri.scheme.in?(%w[http https])
      uri.to_str
    else
      nil
    end
  end

  private

  def consistent_post_and_parent
    if parent_comment && parent_comment.post_id != post_id
      errors.add(:parent_comment, 'must belong to the same post')
    end
  end

end
