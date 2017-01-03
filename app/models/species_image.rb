class SpeciesImage < ApplicationRecord
  belongs_to :species
  belongs_to :image, class_name: 'Image'
end
