desc 'Service tasks'
namespace :check do

  desc 'Check that all DB records are valid'
  task :validity => :environment do

    incogt = Species.find(9999)
    [Species, Locus, Observation, Post, Image].each do |model|
      puts "Checking #{model.to_s} records in the DB for validity..."
      model.all.each do |record|
        unless record == incogt
          raise(ActiveRecord::RecordInvalid.new(record)) if record.invalid?
        end
      end
      puts '    done.'
    end

  end
end