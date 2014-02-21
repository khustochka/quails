class Ebird::Submission < ActiveRecord::Base

  belongs_to :ebird_file, class_name: 'Ebird::File', foreign_key: 'ebird_file_id'
  belongs_to :card

end
