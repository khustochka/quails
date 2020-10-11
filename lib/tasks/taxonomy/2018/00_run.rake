# frozen_string_literal: true

namespace :tax do

  namespace :update2018 do

    task :run => [:import_ebird_taxa,
                  :update_taxa,
                  :update_species, :fix_splits_and_lumps,
                  :final_touch, :final_comments]

    task :final_touch => :environment do

      # Update images


      # Update data

      changes = {

          "Ammospiza nelsoni" => {
              authority: "(J. A. Allen, 1875)"
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

    task :final_comments => :environment do
      puts "\n\nWHAT TO DO NEXT:\n\n"

      puts "1. Check everything."
      puts "2. Revise Authority, Russian/French names for split, lumped and renamed species."
      puts "3. Review and update posts where changed species are linked.\n\n"

      posts = Post.
          where("text ilike '%melfus%' OR text ilike '%Melanitta fusca%'").
          select("face_date, slug").
          order("face_date")

      posts.each do |post|
        puts "#{post.face_date}: #{post.slug}"
      end

    end

  end

end
