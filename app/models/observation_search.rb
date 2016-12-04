require 'simple_partial'

class ObservationSearch

  # This makes it act as Model usable to build form

  extend ActiveModel::Naming
  include ActiveModel::Conversion

  def self.model_name
    ActiveModel::Name.new(self, nil, "Q")
  end

  def persisted?
    false
  end

  CARD_ATTRIBUTES = [:observ_date, :end_date, :locus_id, :resolved, :include_subregions]
  OBSERVATION_ATTRIBUTES = [:taxon_id, :voice, :exclude_subtaxa, :card_id]
  ALL_ATTRIBUTES = CARD_ATTRIBUTES + OBSERVATION_ATTRIBUTES

  ALL_ATTRIBUTES.each do |attr|
    attr_accessor attr
  end


  def initialize(conditions = {})
    # TODO: in Rails 5 do ActiveModel::AttributeAssignment and use assign_attributes

    # FIXME: security

    conditions2 = conditions || {}
    all_conditions = conditions2.slice(*ALL_ATTRIBUTES).select { |_, v| v.meaningful? }

    all_conditions.each do |key, val|
      send(:"#{key}=", val)
    end

    normalize_dates

    extend_conditions
  end

  # Overwritten in Ebird::ObsSearch
  def base_cards
    Card.all
  end

  def cards
    @cards_relation ||= build_cards_relation
  end

  def observations
    @obs_relation ||= build_obs_relation
  end

  def observation_filtered?
    OBSERVATION_ATTRIBUTES.any? {|key| send(key).meaningful?}
  end

  def card_filtered?
    CARD_ATTRIBUTES.any? {|key| send(key).meaningful?}
  end

  # Rendering

  def dates_fieldset
    SimplePartial.new('observations/search/dates_fieldset')
  end

  def voice_fieldset
    SimplePartial.new('observations/search/voice_fieldset')
  end

  private

  def normalize_dates
    [:observ_date, :end_date].each do |attr|
      date = send(attr)
      if date.presence.is_a?(String)
        send(:"#{attr}=", Date.parse(date))
      end
    end
  end

  def extend_conditions
    if card_id
      # This is done mostly for map edit. When you edit map for a certain card we want to place the map at the location of the card
      self.locus_id ||= Card.find(card_id).try(:locus_id)
    end
  end

  def build_cards_relation
    cards_rel = bare_cards_relation
    if observation_filtered?
      cards_rel = cards_rel.includes(:observations).references(:observations).merge(bare_obs_relation).preload(observations: {:taxon => :species})
    end
    cards_rel
  end

  def build_obs_relation
    obs_rel = bare_obs_relation.preload(:card)
    if card_filtered?
      obs_rel = obs_rel.joins(:card).merge(bare_cards_relation)
    end
    obs_rel
  end

  def bare_cards_relation
    @bare_cards_relation ||=
        [
            :apply_date_filter,
            :apply_locus_filter,
            :apply_resolved_filter
        ].inject(base_cards) do |scope, filter|
          send(filter, scope)
        end
  end

  def bare_obs_relation
    @bare_obs_relation ||=
        [
            :apply_card_id_filter,
            :apply_taxon_filter,
            :apply_voice_filter
        ].inject(Observation.all) do |scope, filter|
          send(filter, scope)
        end
  end

  def apply_date_filter(cards_scope)
    if observ_date
      dates = if end_date
                observ_date..end_date
              else
                observ_date
              end
      cards_scope.where(observ_date: dates)
    else
      cards_scope
    end

  end

  def apply_locus_filter(cards_scope)
    if locus_id
      loci = if include_subregions
               Locus.find(locus_id).subregion_ids
             else
               locus_id
             end
      cards_scope.where(locus_id: loci)
    else
      cards_scope
    end
  end

  def apply_resolved_filter(cards_scope)
    if resolved
      cards_scope.where(resolved: resolved)
    else
      cards_scope
    end
  end

  def apply_card_id_filter(obs_scope)
    if card_id
      obs_scope.where(card_id: card_id)
    else
      obs_scope
    end
  end

  def apply_taxon_filter(obs_scope)
    if taxon_id
      taxa = if exclude_subtaxa
               taxon_id
             else
               [taxon_id.to_i] + Taxon.where("taxa.parent_id" => taxon_id).pluck(:id)
             end
      obs_scope.where(taxon_id: taxa)
    else
      obs_scope
    end
  end

  def apply_voice_filter(obs_scope)
    if !voice.nil?
      obs_scope.where(voice: voice)
    else
      obs_scope
    end
  end

end
