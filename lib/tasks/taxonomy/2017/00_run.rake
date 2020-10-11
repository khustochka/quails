# frozen_string_literal: true

namespace :tax do

  namespace :update2017 do

    task :run => [:import_ebird_taxa, :update_taxa, :update_species, :fix_splits_and_lumps, :final_touch, :final_comments]

    task :final_comments => :environment do
      puts "\n\nWHAT TO DO NEXT:\n\n"

      puts "1. Check everything."
      puts "2. Revise Authority, Russian/French names for split, lumped and renamed species."
      puts "3. Review and update posts where changed species are linked.\n\n"

      posts = Post.
          where("text ilike '%circya%' OR text ilike '%lanexc%' OR text ilike '%Cicrcus cyaneus%' OR text ilike '%Lanius excubitor%'").
          select("face_date, slug").
          order("face_date")

      posts.each do |post|
        puts "#{post.face_date}: #{post.slug}"
      end

    end

    task :final_touch => :environment do

      # Update images

      hen_harrier = Species.find_by_name_sci("Circus cyaneus")
      nor_harrier = Species.find_by_name_sci("Circus hudsonius")

      hen_harrier.image = nil
      hen_harrier.update_image

      nor_harrier.image = nil
      nor_harrier.update_image

      # Update data

      changes = {
          "Circus hudsonius" => {
              code: "cirhud",
              authority: "(Linnaeus, 1766)",
              name_ru: "Американский лунь",
              name_fr: "Busard des marais"
          },
          "Lanius borealis" => {
              code: "lanbor",
              authority: "Vieillot, 1808",
              name_ru: "Северный сорокопут",
              name_fr: "Pie-grièche boréale"
          },
          "Linaria flavirostris" => {
              authority: "(Linnaeus, 1758)"
          },
          "Linaria cannabina" => {
              authority: "(Linnaeus, 1758)"
          },
          "Anser rossii" => {
              authority: "Cassin, 1861"
          },
          "Spatula discors" => {
              authority: "(Linnaeus, 1766)"
          },
          "Spatula querquedula" => {
              authority: "(Linnaeus, 1758)"
          },
          "Spatula clypeata" => {
              authority: "(Linnaeus, 1758)"
          },
          "Spatula cyanoptera" => {
              authority: "(Vieillot, 1816)"
          },
          "Mareca strepera" => {
              authority: "(Linnaeus, 1758)"
          },
          "Mareca penelope" => {
              authority: "(Linnaeus, 1758)"
          },
          "Mareca americana" => {
              authority: "(Gmelin, JF, 1789)"
          },
          "Sibirionetta formosa" => {
              authority: "(Georgi, 1775)"
          },
          "Tetrastes bonasia" => {
              authority: "(Linnaeus, 1758)"
          }
      }

      puts "\n\nUpdating Authority, French, Russian names:\n"

      changes.each do |nm, attr|
        Species.find_by_name_sci(nm).update(attr)
        puts nm
      end

    end

  end

end
