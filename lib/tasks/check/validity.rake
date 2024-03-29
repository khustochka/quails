# frozen_string_literal: true

desc "Service tasks"
namespace :check do
  desc "Check that all DB records are valid"
  task validity: :environment do
    [Species, Locus, Observation, Post, Image, Book, Comment, Spot, Taxon].each do |model|
      puts "Checking #{model} records in the DB for validity..."
      model.to_a.each do |record|
        raise ActiveRecord::RecordInvalid, record if record.invalid?
      end
      puts "    done."
    end
  end
end
