class Comment < ActiveRecord::Base

  STOP_WORDS = %w( replica vuitton generic zithromax cheap cialis payday loans pharmacy url=http link=http
                    viagra tricor accutane seroquel retin lasix )

  ALLOWED_PARAMETERS = [:text, :parent_id]

  include FormattedModel

  validates :text, :name, :post_id, :presence => true

  belongs_to :post, touch: :commented_at
  has_many :subcomments, :class_name => 'Comment', :foreign_key => :parent_id, :dependent => :destroy
  belongs_to :parent_comment, :class_name => 'Comment', :foreign_key => :parent_id
  belongs_to :commenter

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

end
