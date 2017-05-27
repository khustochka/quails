class Day

  attr_reader :date

  def initialize(str)
    @date = Date.parse(str)
  end

  def prev
    @date - 1.day
  end

  def next
    @date + 1.day
  end

  def cards
    @cards ||= Card.where(observ_date: date)
  end

  def observations
    @observations ||= Observation.where(card_id: @cards)
  end

  def species
    @species ||=
        Species.distinct.joins(:cards, :observations).merge(cards).order(:index_num)
  end

  def new_species_ids
    subquery = "
      select obs.id
          from observations obs
          join cards c on obs.card_id = c.id
          join taxa tt ON obs.taxon_id = tt.id
          where taxa.species_id = tt.species_id
          and cards.observ_date > c.observ_date"
    @new_species_ids ||= MyObservation.
        joins(:card).
        merge(cards).
        where("NOT EXISTS(#{subquery})").
        pluck("DISTINCT species_id")
  end

  def images
    Image.joins(:observations, :cards).includes(:cards, :taxa).merge(cards).
        merge(Card.default_cards_order("ASC")).
        order('media.index_num, taxa.index_num').preload(:species)
  end

  def posts
    posts_id = cards.where("post_id IS NOT NULL").pluck("DISTINCT post_id") +
        observations.where("observations.post_id IS NOT NULL").pluck("DISTINCT observations.post_id")
    Post.distinct.where(id: posts_id)
  end

end
