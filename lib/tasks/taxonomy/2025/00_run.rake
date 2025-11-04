# frozen_string_literal: true

namespace :tax do
  namespace :update2025 do
    task run: [
      :split_observations,
      :import_ebird_taxa,
      :update_taxa,
      :update_species,
      :fix_splits_and_lumps,
      :final_touch,
      :final_comments
    ]

    task final_touch: :environment do
      # Update images

      Species.find_by(name_sci: "Numenius phaeopus").update_image!
      Species.find_by(name_sci: "Numenius hudsonicus").update_image

      # Update data

      changes = {
        "Numenius hudsonicus" => {
            authority: "Latham, J 1790",
            name_fr: "Courlis hudsonien",
            name_ru: "Американский средний кроншнеп"
        },
        "Setophaga aestiva" => {
            authority: "(Gmelin, 1789)",
            name_ru: "Желтая древесница",
            name_fr: "Paruline jaune"
        }
      }

      puts "\n\nUpdating Authority, French, Russian names:\n"

      changes.each do |nm, attr|
        Species.find_by_name_sci(nm).update(attr)
        puts nm
      end

      # Clear cache

      Rails.cache.clear
    end

    task final_comments: :environment do
      puts "\n\nWHAT TO DO NEXT:\n\n"

      puts "1. Check everything."
      puts "2. Revise Authority, Russian/French names for split, lumped and renamed species."
      puts "3. Review and update posts where changed species are linked.\n\n"

      posts = Post.
          where("body ilike '%Numenius phaeopus%' or body ilike '%petechia%'").
          select("face_date, slug").
          order("face_date")

      posts.each do |post|
        puts "#{post.face_date}: #{post.slug}"
      end
    end
  end
end
