require 'test_helper'

class DBIntegrityTest < ActionDispatch::IntegrationTest

  test 'all records in the db are valid' do
    [Species, Locus, Observation, Post].each do |model|
#      puts "-- [INFO] Checking #{model.to_s} records in the DB for validity"
      model.all.each do |record|
        assert record.valid?
      end
    end

  end
end