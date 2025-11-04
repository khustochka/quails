# frozen_string_literal: true

namespace :tax do
  namespace :update2025 do
    task :split_observations => :environment do
      # == Warbling Vireo

      old_wavi = EBirdTaxon.find_by_ebird_code("warvir")
      east_wavi = EBirdTaxon.find_by_ebird_code("eawvir1").promote

      Observation.joins(card: :locus).where(taxon: old_wavi).each do |obs|
        next if obs.card.locus.slug == "confederation_park"
        obs.update!(taxon: east_wavi)
      end

      # == Yellow Warbler

      old_yewa = EBirdTaxon.find_by_ebird_code("yelwar")
      north_yewa = EBirdTaxon.find_by_ebird_code("yelwar1").promote

      Observation.where(taxon: old_yewa).each do |obs|
        obs.update!(taxon: north_yewa)
      end

      # == WHimbrel

      old_whim = EBirdTaxon.find_by_ebird_code("whimbr")
      huds_whim = EBirdTaxon.find_by_ebird_code("whimbr3").promote

      Observation.where(taxon: old_whim).each do |obs|
        obs.update!(taxon: huds_whim)
      end
    end
  end
end
