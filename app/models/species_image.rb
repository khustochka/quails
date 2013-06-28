class SpeciesImage < ActiveRecord::Base
  belongs_to :species
  belongs_to :image
end
