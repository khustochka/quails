desc 'Test benchmark'
task :test_bm => :environment do
  require 'benchmark'
  require 'test/unit'

  n = 100
  Benchmark.bmbm do |x|

    x.report('2nd') { n.times {
      Rails.logger.info "\n ***************** 2nd **************** \n"
      Observation.lifelist.all
    } }

    x.report('3rd') { n.times {
      Rails.logger.info "\n ***************** 3rd **************** \n"
      res = Observation.find_by_sql("SELECT *
          FROM observations
          WHERE (species_id, observ_date) IN (
            SELECT species_id, MIN(observ_date)
            FROM observations
            WHERE mine = true AND species_id != 9999
            GROUP BY species_id
            )
          ORDER BY observ_date DESC").group_by(&:species_id).map { |k, v| v.first }
      Observation.send(:preload_associations, res, [:species, :post])
    } }

    x.report('OLD') { n.times {
      Rails.logger.info "\n ***************** OLD **************** \n"
      Species.old_lifelist
    } }

    x.report('4th') { n.times {
      Rails.logger.info "\n ***************** 4th **************** \n"
      subquery = Observation.identified.mine.select("species_id, MIN(observ_date)").group('species_id').to_sql
      res = Observation.where("(species_id, observ_date) IN (#{subquery})").
          order("observ_date DESC").preload(:species, :post).all
      res.group_by(&:species_id).map { |k, v| v.first }
    } }

    x.report('JOI') { n.times {
      Rails.logger.info "\n ***************** JOI **************** \n"
      res = Observation.find_by_sql("
          SELECT obs.species_id, observ_date, name_sci, name_en, name_ru, name_uk, posts.code, face_date
          FROM observations AS obs
            JOIN (
              SELECT species_id, MIN(observ_date) as mdate
              FROM observations
              WHERE mine = true AND species_id != 9999
              GROUP BY species_id
            ) AS mins
            ON (obs.species_id = mins.species_id AND obs.observ_date = mins.mdate)
            JOIN species ON (mins.species_id = species.id)
            LEFT JOIN posts ON (obs.post_id = posts.id)
          WHERE mine = true
          ORDER BY observ_date DESC
          "
      )
      res.group_by(&:species_id).map { |k, v| v.first }
    } }
  end
end