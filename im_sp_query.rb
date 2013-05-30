require "./config/environment"

c = Country.find_by_slug!('ukraine')

book = Book.find_by_slug('fesenko-bokotej')

puts c.local_species.select("DISTINCT species.name_sci").joins(:taxa => {:species => :images}).merge(book.taxa.scoped).except(:order).where("NOT EXISTS (SELECT images.id FROM images INNER JOIN images_observations on images.id = images_observations.image_id INNER JOIN observations ON observations.id = images_observations.observation_\id WHERE species_id = species.id AND flickr_id IS NOT NULL)").pluck("DISTINCT species.name_sci")
