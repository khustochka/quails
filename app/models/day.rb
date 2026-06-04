# frozen_string_literal: true

class Day
  attr_reader :date

  def initialize(date)
    @date = date
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
      Species.distinct.joins(:cards).merge(cards).order(:index_num)
  end

  def lifer_species_ids
    subquery = "
      select obs.id
          from observations obs
          join cards c on obs.card_id = c.id
          where obs.species_id = observations.species_id
          and cards.observ_date > c.observ_date"
    @lifer_species_ids ||= Observation.identified
      .joins(:card)
      .merge(cards)
      .where("NOT EXISTS(#{subquery})")
      .distinct
      .pluck(:species_id)
  end

  def images
    Image.joins(:observations, :cards).includes(:cards, :taxa).merge(cards)
      .merge(Card.default_cards_order("ASC"))
      .order("media.index_num, taxa.index_num").preload(:species)
  end

  def post_cores
    PostCore.where(id: cards.where.not(post_core_id: nil).select(:post_core_id))
      .or(PostCore.where(id: observations.where.not(observations: { post_core_id: nil }).select(:post_core_id)))
  end

  def posts(scope: Post.public_posts)
    scope.where(post_core_id: post_cores).order(:post_core_id, :lang)
  end
end
