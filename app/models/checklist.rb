class Checklist < ActiveRecord::Base
  belongs_to :locus
  belongs_to :species
end
