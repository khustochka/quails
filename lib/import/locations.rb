require 'lib/import/legacy/models/geography'
require 'app/models/country'
require 'iconv'

module Import
  class Location

    def self.get_legacy

      Legacy::Country.establish_legacy_connection

      Legacy::Country.all.each do |country|
        Country.create!({
                :code => country[:country_id],
                :name_ru => Iconv.iconv('utf-8', 'cp1251', country[:country_name]).to_s,
                :parent_id => nil
        })
      end

    end

  end
end