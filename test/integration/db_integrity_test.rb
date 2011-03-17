require 'test_helper'

class DBIntegrityTest < ActionDispatch::IntegrationTest

  test 'all records in the db are valid' do
    incogt = Species.find(0)
    [Species, Locus, Observation, Post].each do |model|
#      puts "-- [INFO] Checking #{model.to_s} records in the DB for validity"
      model.all.each do |record|
        assert(record.valid?, "Invalid record: #{record.inspect}") unless record == incogt
      end
    end
  end

  test 'DB collation is correct for sorting' do
    sps = Species.alphabetic.where("name_sci LIKE 'Passer%'").all
    assert sps.index{|s| s.name_sci == 'Passer montanus'} < sps.index{|s| s.name_sci == 'Passerina caerulea'},
      'Incorrect sorting order (set LC_COLLATE)'
  end

end