# frozen_string_literal: true

Locus.transaction do
  # rubocop:disable Lint/MissingCopEnableDirective
  # rubocop:disable Lint/UselessAssignment
  europe = Locus.create!(name_en: "Europe", name_uk: "Європа", loc_type: "continent", public_index: 7)
  north_america = Locus.create!(name_en: "North America", name_uk: "Північна Америка", loc_type: "continent", public_index: 8)

  ukraine = Locus.create!(name_en: "Ukraine", name_uk: "Україна", loc_type: "country", iso_code: "UA", parent: europe, public_index: 1)
  uk = Locus.create!(name_en: "United Kingdom", name_uk: "Велика Британія", loc_type: "country", iso_code: "GB", parent: north_america, public_index: 6)

  canada = Locus.create!(name_en: "Canada", name_uk: "Канада", loc_type: "country", iso_code: "CA", parent: europe, public_index: 10)
  usa = Locus.create!(slug: "usa", name_en: "United States", name_uk: "США", loc_type: "country", iso_code: "US", parent: north_america, public_index: 9)

  kyiv_obl = Locus.create!(name_en: "Kyiv Oblast", name_uk: "Київська область", loc_type: "oblast", iso_code: "32", parent: ukraine, public_index: 3)
  kherson_obl = Locus.create!(name_en: "Kherson Oblast", name_uk: "Херсонська область", loc_type: "oblast", iso_code: "65", parent: ukraine, public_index: 4)
  brovary = Locus.create!(name_en: "Brovary", name_uk: "Бровари", loc_type: "city", parent: kyiv_obl, public_index: 2)
  arabat_spit = Locus.create!(name_en: "Arabat Spit", name_uk: "Арабатська стрілка", parent: kherson_obl, public_index: 5)

  scotland = Locus.create!(name_en: "Scotland", name_uk: "Шотландія", loc_type: "subcountry", parent: uk)

  manitoba = Locus.create!(name_en: "Manitoba", name_uk: "Манітоба", loc_type: "province", iso_code: "MB", parent: canada, public_index: 11)
  winnipeg = Locus.create!(name_en: "Winnipeg", name_uk: "Вінніпег", loc_type: "city", parent: manitoba, public_index: 12)

  ny = Locus.create!(name_en: "New York", name_uk: "шт. Нью-Йорк", loc_type: "state", iso_code: "NY", parent: usa)

  # rubocop:enable Lint/UselessAssignment
  # rubocop:enable Lint/MissingCopEnableDirective

  hosp = Taxon.create!(
    name_sci: "Passer domesticus",
    name_en: "House Sparrow",
    category: "species",
    order: "Passeriformes",
    family: "Passeridae (Old World Sparrows)",
    index_num: 1,
    ebird_code: "houspa",
    parent_id: nil,
    taxon_concept_id: "avibase-240E3390",
  )
  hosp.lift_to_species
end
