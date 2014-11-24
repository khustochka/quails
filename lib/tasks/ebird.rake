# -- encoding: utf-8 --

desc 'Generate eBird CSV file'
task :ebird => :environment do

  require 'csv'

  include ActionView::Helpers::AssetTagHelper
  include ActionView::Helpers::UrlHelper

  include ActiveSupport::Inflector

  clements_id = Book.where(slug: "clements6").first.id

  obs = Observation.
      where("place ILIKE '%Байково%' AND place <> 'у Байкового' AND place <> 'ок. Байкового кладбища'").
      preload(:species, :card, :images)

  arr = obs.map do |o|

    sp_data = if o.species_id == 0
                [o.notes, o.notes]
              else
                sp = o.species.taxa.where(book_id: clements_id).first
                [sp.name_en, sp.name_sci]
              end

    [
        sp_data[0],
        nil,
        sp_data[1],
        o.quantity[/(\d+(\s*\+\s*\d+)?)/, 1],
        (
            [transliterate(o.notes)] +
            o.images.map { |i| polimorfic_image_render(i) }
        ).join(" "),
        "Baikove Cemetery",
        nil,
        nil,
        o.card.observ_date.strftime("%m/%d/%Y"),
        "13:00",
        "0",
        "UA",
        o.card.observ_date == '2012-02-22' ? 'incidental' : "traveling",
        21,
        "120",
        "Y",
        "1",
        nil,
        "Start time, duration and distance are not exact"
    ]
  end

  CSV.open("baikove.csv", "w") do |csv|
    arr.each do |row|
      csv << row
    end
  end

end

def polimorfic_image_render(img)
  if img.on_flickr?
    ff = FlickrPhoto.new(img)
    link_to image_tag(img.assets_cache.externals.find_max_size(width: 600).download_url, alt: nil), ff.page_url
  else
    image_tag(img.assets_cache.locals.find_max_size(width: 600).try(:full_url) || legacy_image_url("#{img.slug}.jpg"), alt: nil)
  end
end
