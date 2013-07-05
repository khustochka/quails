desc 'Quick benchmark'
task :benchmark => :environment do
  require 'benchmark'

  post = Post.find(555)

  n = 10
  Benchmark.bmbm do |x|

    x.report('window 1') { n.times {

      q1 = MyObservation.
          joins(:card).
          select("distinct on (species_id) species_id, card_id, observations.post_id as ob_post_id, cards.post_id as card_post_id").
          order("species_id, observ_date")

      r1 = Observation.
          from("(#{q1.to_sql}) as subq").
          where("ob_post_id = ? or card_post_id = ?", post.id, post.id).
          pluck("species_id")

      raise r1.size.to_s unless r1.size == 7

    } }

    x.report('window 2') { n.times {

      q2 = MyObservation.
          joins(:card).
          select("distinct on (species_id) observations.id").
          order("species_id, observ_date")

      r2 = Observation.
          joins(:card).
          where(id: q2).
          where("observations.post_id = ? or cards.post_id = ?", post.id, post.id).
          pluck(:species_id)

      raise r2.size.to_s unless r2.size == 7

    } }

    x.report('not exists') { n.times {

      q3 = "select obs.id from observations obs join cards c on obs.card_id = c.id where observations.species_id = obs.species_id and cards.observ_date > c.observ_date and obs.mine"

      r3 = Observation.
          joins(:card).
          where("observations.post_id = ? or cards.post_id = ?", post.id, post.id).
          where("NOT EXISTS(#{q3})").
          pluck(:species_id)

      raise r3.size.to_sql unless r3.size == 7
    } }

    x.report('lifelist preload') { n.times {


    } }

  end
end
