# -- encoding: utf-8 --

require 'csv'

desc 'Generate eBird CSV file'
task :ebird => :environment do

  include ActiveSupport::Inflector

  obs = Observation.where(mine: true).
      where("place ILIKE '%Байково%' AND place <> 'у Байкового' AND place <> 'ок. Байкового кладбища'").
      preload(:species)

  arr = obs.map do |o|
    [
        o.species_id != 0 ? o.species.name_en : o.notes,
        nil,
        o.species_id != 0 ? o.species.name_sci : o.notes,
        o.quantity[/(\d+)/, 1],
        (
            [transliterate(o.notes)] +
            o.images.map { |i| %Q(<img src="http://birdwatch.org.ua/photos/#{i.slug}.jpg">) }
        ).join(" "),
        "Baikove Cemetery",
        nil,
        nil,
        o.observ_date.strftime("%m/%d/%Y"),
        "13:00",
        "0",
        "UA",
        o.observ_date == '2012-02-22' ? 'incidental' : "traveling",
        1,
        "60",
        "Y",
        "1",
        nil,
        "Start time, duration and distance are dummy values"
    ]
  end

  CSV.open("baikove.csv", "w") do |csv|
    arr.each do |row|
      csv << row
    end
  end

end
