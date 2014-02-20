class Ebird::File < ActiveRecord::Base

  STATUSES = %w( NEW POSTED REMOVED IRRELEVANT )

  validates :name, presence: true
  validates :status, inclusion: STATUSES, allow_blank: false

end
