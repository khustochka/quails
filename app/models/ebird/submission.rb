class Ebird::Submission < ActiveRecord::Base

  belongs_to :ebird_file, :class_name => 'Ebird::File'
  belongs_to :card

end
