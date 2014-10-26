class Ebird::File < ActiveRecord::Base

  STATUSES = %w( NEW POSTED REMOVED INVALID )

  TRANSITIONS = {
      'NEW' => %w( POSTED REMOVED INVALID ),
      'POSTED' => %w( REMOVED INVALID ),
      'REMOVED' => %w( POSTED INVALID ),
      'INVALID' => []
  }

  class Transition < Struct.new(:file_id, :status)
    def to_partial_path
      'transition'
    end
  end

  validates :name, presence: true
  validates :status, inclusion: STATUSES, allow_blank: false

  has_many :ebird_submissions, :class_name => 'Ebird::Submission', foreign_key: 'ebird_file_id', dependent: :delete_all
  has_many :cards, through: :ebird_submissions

  def download_url
    "/csv/#{name}.csv"
  end

  # Is there any card updated after file generation
  def outdated?
    cards.where('updated_at > ?', self.created_at).exists?
  end

  def transitions
    TRANSITIONS[status].map {|t| Transition.new(self.id, t) }
  end

end
