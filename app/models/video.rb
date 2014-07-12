class Video < ActiveRecord::Base

  has_and_belongs_to_many :observations, join_table: 'videos_observations'
  has_many :species, through: :observations

  # TODO: try to make it 'card', because image should belong to observations of the same card
  has_many :cards, through: :observations

  has_many :spots, through: :observations
  belongs_to :spot


  def mapped?
    spot_id
  end

end
