class Ebird::File < ActiveRecord::Base

  STATUSES = %w( NEW POSTED REMOVED IRRELEVANT )

  validates :name, presence: true
  validates :status, inclusion: STATUSES, allow_blank: false

  has_many :ebird_submissions, :class_name => 'Ebird::Submission'
  has_many :cards, through: :ebird_submissions

end
