# frozen_string_literal: true

# Interactive depatch
task :depatch => :environment do

  cards = Card.
      where(id: Observation.select(:card_id).
          where.not(patch_id: nil)).order(:observ_date).
      where.not(effort_type: "TRAVEL").
      where(ebird_id: nil).
      where(start_time: nil).
      preload(:locus, :observations)

  puts "There are #{cards.count} cards with patches"

  total = cards.count

  cards.each_with_index do |card, ind|
    puts "\n\n\n================\nAnalyzing card #{card.id} (#{ind + 1} of #{total})"
    puts "Locus: #{card.locus.name_en}"
    [:observ_date, :notes, :effort_type, :ebird_id].each do |attr|
      puts "#{attr}: #{card[attr]}"
    end

    patches = card.observations.except(:order).group(:patch_id).count
    patches = patches.map {|pp, count| [pp && Locus.find(pp), count]}

    while patches.size > 1
      x = nil
      while x.nil? || (x.to_i != 0 && x.to_i > patches.size)
        puts "\nPatches:"
        patches.each_with_index do |(patch, count), i|
          puts "#{i + 1}. #{patch&.name_en || "None"}: #{count}"
        end
        puts "Enter patch to extract: S to skip"
        x = STDIN.gets.strip
      end


      if x.to_i > 0
        selected_index = x.to_i - 1
        patch = patches[selected_index][0]

        puts "Processing patch #{patch&.name_en || "Default"}"
        obs = card.observations.where(patch_id: patch&.id)
        obs.each do |ob|
          puts "#{ob.id}: Priv: #{ob.private_notes % "%30s"}, Notes: #{ob.notes % "%30s"}"
        end
        puts "Extraxt this patch: 1. Clear priv notes. 2. Move priv notes to notes, 3. Leave notes as is"
        puts "S - skip, show patches"
        x = STDIN.gets.strip
        if x.to_i > 0 && x.to_i < 4
          new_card = card.dup
          new_card.locus = patch if patch
          new_card.observations << obs
          new_card.save!
          new_card.observations.update_all(patch_id: nil)
          if patch # DO not clear or move notes for default patch
            if x.to_i == 2
              new_card.observations.each do |ob|
                ob.update! notes: [:notes, :private_notes].map {|att| ob[att].presence}.compact.join("; ")
              end
            end
            if x.to_i == 1 || x.to_i == 2
              new_card.observations.update_all(private_notes: "")
            end
          end
          patches.delete_at(selected_index)
          puts "New card created: #{new_card.id}"
          puts "Press any key"
          STDIN.gets
          card.reload
        end
      else
        break
      end
    end
    if patches.size == 1 and patches[0][0] != nil
      puts "Will switch locus to patch: card #{card.id}"
      card.observations.each do |ob|
        puts "#{ob.id}: Priv: #{ob.private_notes % "%30s"}, Notes: #{ob.notes % "%30s"}"
      end
      puts "1. Clear priv notes. 2. Move priv notes to notes, 3. Leave notes as is"
      x = STDIN.gets.strip
      card.update! locus: patches[0][0]

      card.observations.update_all(patch_id: nil)
      if x.to_i == 2
        card.observations.each do |ob|
          ob.update! notes: [:notes, :private_notes].map {|att| ob[att].presence}.compact.join("; ")
        end
      end
      if x.to_i == 1 || x.to_i == 2
          card.observations.update_all(private_notes: "")
      end
      puts "Press any key"
      x = STDIN.gets.strip
    end

  end
end
