desc 'Service tasks'
namespace :check do

  desc 'Check that DB collation is correct'
  task :collation => :environment do

    sps = Species.alphabetic.where("name_sci LIKE 'Passer%'")
    if sps.index { |s| s.name_sci == 'Passer montanus' } >= sps.index { |s| s.name_sci == 'Passerina caerulea' }
      raise 'Incorrect sorting order (set LC_COLLATE = "C" to fix)'
    else
      puts 'DB collation is correct'
    end

  end

end
