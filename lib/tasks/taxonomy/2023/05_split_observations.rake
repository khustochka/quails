# frozen_string_literal: true

namespace :tax do
  namespace :update2023 do
    task :split_observations => :environment do
      na_locs = Locus.find_by_slug("north_america").subregion_ids
      eu_locs = Locus.find_by_slug("europe").subregion_ids

      # == Goshawk

      goshawk = EBirdTaxon.find_by_ebird_code("norgos")
      eu_goshawk = EBirdTaxon.find_by_ebird_code("norgos1").promote
      am_goshawk = EBirdTaxon.find_by_ebird_code("norgos2").promote

      Observation.joins(:card).where(taxon: goshawk, card: {locus_id: na_locs}).each do |obs|
        obs.update!(taxon: am_goshawk)
      end

      Observation.joins(:card).where(taxon: goshawk, card: {locus_id: eu_locs}).each do |obs|
        obs.update!(taxon: eu_goshawk)
      end

      # == Cattle Egret

      categr = EBirdTaxon.find_by_ebird_code("categr")
      west_categr = EBirdTaxon.find_by_ebird_code("categr1").promote

      Observation.where(taxon: categr).each do |obs|
        obs.update!(taxon: west_categr)
      end

      # == Gull-billed Tern

      gubter = EBirdTaxon.find_by_ebird_code("gubter1")
      eu_gubter = EBirdTaxon.find_by_ebird_code("gubter2").promote

      Observation.where(taxon: gubter).each do |obs|
        obs.update!(taxon: eu_gubter)
      end

      # == House Martin

      homar = EBirdTaxon.find_by_ebird_code("cohmar1")
      west_homar = EBirdTaxon.find_by_ebird_code("comhom1").promote

      Observation.where(taxon: homar).each do |obs|
        obs.update!(taxon: west_homar)
      end
    end
  end
end
