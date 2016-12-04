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

  def method_missing(method)
    if method.in?(ALL_ATTRIBUTES)
      @all_conditions[method]
    else
      super
    end
  end

  CARD_ATTRIBUTES = [:observ_date, :end_date, :locus_id, :card_id, :resolved, :include_subregions]
  OBSERVATION_ATTRIBUTES = [:taxon_id, :voice, :exclude_subtaxa]
  ALL_ATTRIBUTES = CARD_ATTRIBUTES + OBSERVATION_ATTRIBUTES

  def initialize(conditions = {})
    conditions2 = conditions.to_h || {}
    @all_conditions = conditions2.slice(*ALL_ATTRIBUTES).reject { |_, v| v.blank? && v != false }

    normalize_dates

    @conditions = {
        card: @all_conditions.slice(*CARD_ATTRIBUTES),
        observation: @all_conditions.slice(*OBSERVATION_ATTRIBUTES)
    }

    extend_conditions
  end

  # Overwritten in Ebird::ObsSearch
  def base_cards
    Card.all
  end

  def cards
    build_relations unless @cards_relation
    @cards_relation
  end

  def observations
    build_relations unless @obs_relation
    @obs_relation
  end

  def observations_filtered?
    @conditions[:observation].present?
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
      date = @all_conditions[attr]
      if date.presence.is_a?(String)
        @all_conditions[attr] = Date.parse(date)
      end
    end
  end

  def extend_conditions
    if card_id = @conditions[:card].delete(:card_id)
      @conditions[:card][:id] = card_id
      @conditions[:card][:locus_id] ||= Card.find(card_id).try(:locus_id)
      @all_conditions[:locus_id] ||= @conditions[:card][:locus_id]
    end
  end

  def build_relations
    cards_scope = base_cards
    obs_scope = Observation.all

    cards_scope =
        [
            :apply_card_id_filter,
            :apply_date_filter,
            :apply_locus_filter,
            :apply_resolved_filter
        ].inject(cards_scope) do |scope, filter|
          send(filter, scope)
        end

    obs_scope =
        [
            :apply_taxon_filter,
            :apply_voice_filter
        ].inject(obs_scope) do |scope, filter|
          send(filter, scope)
        end

    cards_scope_final = cards_scope
    if observations_filtered?
      cards_scope_final = cards_scope_final.includes(:observations).references(:observations).merge(obs_scope).preload(observations: {:taxon => :species})
    end

    obs_scope_final = obs_scope.preload(:card)
    if @conditions[:card].present?
      obs_scope_final = obs_scope_final.joins(:card).merge(cards_scope)
    end

    @cards_relation = cards_scope_final
    @obs_relation = obs_scope_final
  end

  def apply_card_id_filter(cards_scope)
    if card_id = @conditions[:card][:id]
      cards_scope.where(id: card_id)
    else
      cards_scope
    end
  end

  def apply_date_filter(cards_scope)
    if observ_date = @conditions[:card][:observ_date]
      dates = if end_date = @conditions[:card][:end_date]
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
    if loc = @conditions[:card][:locus_id]
      loci = if @conditions[:card][:include_subregions]
               Locus.find(loc).subregion_ids
             else
               loc
             end
      cards_scope.where(locus_id: loci)
    else
      cards_scope
    end
  end

  def apply_resolved_filter(cards_scope)
    if resolved = @conditions[:card][:resolved]
      cards_scope.where(resolved: resolved)
    else
      cards_scope
    end
  end

  def apply_taxon_filter(obs_scope)
    if tx = @conditions[:observation][:taxon_id]
      taxa = if @conditions[:observation][:exclude_subtaxa]
               tx
             else
               [tx.to_i] + Taxon.where("taxa.parent_id" => tx).pluck(:id)
             end
      obs_scope.where(taxon_id: taxa)
    else
      obs_scope
    end
  end

  def apply_voice_filter(obs_scope)
    voice = @conditions[:observation][:voice]
    if !voice.nil?
      obs_scope.where(voice: voice)
    else
      obs_scope
    end
  end

end
