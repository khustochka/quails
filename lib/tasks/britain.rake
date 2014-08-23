namespace :britain do

  desc "Add GB, England, and London"
  task :england => :environment do
    gb = Locus.new(slug: 'united_kingdom', name_en: 'Great Britain', name_ru: 'Великобритания',
                   name_uk: 'Велика Британія')
    gb.save!

    eng = Locus.new(slug: 'england', name_en: 'England', name_ru: 'Англия',
                    name_uk: 'Англія', parent_id: gb.id)
    eng.save!

    lond = Locus.new(slug: 'london', name_en: 'London', name_ru: 'Лондон',
                     name_uk: 'Лондон', parent_id: eng.id, lat: 51.507222, lon: -0.1275)
    lond.save!
  end

  desc "Add Scotland, Glasgow, and Bishopbriggs"
  task :scotland => :environment do
    gb = Locus.find_by(slug: 'united_kingdom')

    scot = Locus.new(slug: 'scotland', name_en: 'Scotland', name_ru: 'Шотландия',
                    name_uk: 'Шотландія', parent_id: gb.id)
    scot.save!

    glas = Locus.new(slug: 'glasgow', name_en: 'Glasgow', name_ru: 'Глазго',
                     name_uk: 'Глазго', parent_id: scot.id, lat: 55.858, lon: -4.259)
    glas.save!

    bbrig = Locus.new(slug: 'bishopbriggs', name_en: 'Bishopbriggs', name_ru: 'Бишопбриггс',
                      name_uk: 'Бішопбріггс', parent_id: scot.id, lat: 55.9081, lon: -4.21875)
    bbrig.save!
  end

end
