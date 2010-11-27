require 'test_helper'

class DBIntegrityTest < ActionDispatch::IntegrationTest

  test 'all records in the db are valid' do
    [Species, Locus, Observation, Post].each do |model|
      puts model.to_s
      model.all.each do |record|
#        puts record.id
        assert record.valid?
      end
    end

  end
end