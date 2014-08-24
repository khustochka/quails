class Video < ActiveRecord::Base
  include Observationable
  include FormattedModel

  NORMAL_PARAMS = [:slug, :title, :youtube_id, :description]

  has_and_belongs_to_many :observations, join_table: 'videos_observations'
  has_many :species, through: :observations

  # TODO: try to make it 'card', because image should belong to observations of the same card
  has_many :cards, through: :observations

  has_many :spots, through: :observations
  belongs_to :spot

  validates :slug, uniqueness: true, presence: true, length: {:maximum => 64}

  def to_param
    slug_was
  end

  def mapped?
    spot_id
  end

  # Update

  def observation_ids=(list)
    super(list.uniq)
  end

  def youtube_url
    "//www.youtube.com/watch?v=#{youtube_id}"
  end

  def small
    YoutubeVideo.new(youtube_id, 560, 315)
  end

end
