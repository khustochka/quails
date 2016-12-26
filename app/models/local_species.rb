class LocalSpecies < ApplicationRecord

  include ActiveRecord::Localized
  localize :notes

  delegate :order, :family, to: :species

  belongs_to :locus
  belongs_to :species
  has_one :image, through: :species

  # Formatting

  def to_thumbnail
    Thumbnail.new(species, {partial: 'species/thumb_title'}, species.image)
  end

end
