# frozen_string_literal: true

namespace :tax do
  namespace :update2024 do
    task :split_observations => :environment do
      na_locs = Locus.find_by_slug("north_america").subregion_ids
      eu_locs = Locus.find_by_slug("europe").subregion_ids

      # == Herring Gull

      hgull = EBirdTaxon.find_by_ebird_code("hergul")
      eu_hgull = EBirdTaxon.find_by_ebird_code("euhgul1").promote
      am_hgull = EBirdTaxon.find_by_ebird_code("amhgul1").promote

      Observation.joins(:card).where(taxon: hgull, card: {locus_id: na_locs}).each do |obs|
        obs.update!(taxon: am_hgull)
      end

      Observation.joins(:card).where(taxon: hgull, card: {locus_id: eu_locs}).each do |obs|
        obs.update!(taxon: eu_hgull)
      end

      # == Nutcracker

      eur_nut = EBirdTaxon.find_by_ebird_code("eurnut1")
      north_nut = EBirdTaxon.find_by_ebird_code("eurnut3").promote

      Observation.where(taxon: eur_nut).each do |obs|
        obs.update!(taxon: north_nut)
      end

      # # == Gull-billed Tern

      # gubter = EBirdTaxon.find_by_ebird_code("gubter1")
      # eu_gubter = EBirdTaxon.find_by_ebird_code("gubter2").promote

      # Observation.where(taxon: gubter).each do |obs|
      #   obs.update!(taxon: eu_gubter)
      # end

      # # == House Martin

      # homar = EBirdTaxon.find_by_ebird_code("cohmar1")
      # west_homar = EBirdTaxon.find_by_ebird_code("comhom1").promote

      # Observation.where(taxon: homar).each do |obs|
      #   obs.update!(taxon: west_homar)
      # end
    end
  end
end
