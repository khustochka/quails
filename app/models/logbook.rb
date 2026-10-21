# frozen_string_literal: true

# Feed of additions to lists: for each date, species seen for the first time
# ever (+:life+) or in a calendar year (+:year+) in the World or in an area,
# for the lists enabled in LogbookSetting.
#
# A species added to several lists on the same day is reported once, under
# the most significant list: life beats year, and an area beats its subareas
# (the World beats everything). Life lists of subareas that the species was
# also added to are kept as annotations (+covered+), e.g. a lifer that is also
# new for Manitoba. Species sharing the same list and annotations on a date
# are grouped into one entry.
class Logbook
  # +locus+ is nil for the World, +year+ is nil for life lists. +list_total+
  # is the size of the list after the last of +observations+ was added.
  # +covered+ is [[locus, list_total]].
  Entry = Struct.new(:type, :locus, :year, :observations, :list_total, :covered, keyword_init: true)

  DEFAULT_LIMIT = 5
  DEFAULT_CUTOFF_DAYS = 93

  def initialize(observation_scope: Observation.all, settings: LogbookSetting.enabled.to_a)
    @observation_scope = observation_scope
    @settings = settings.select { |setting| setting.life || setting.year }
  end

  # Most recent dates with entries, newest first, as [[date, [Entry]]].
  def recent(limit: DEFAULT_LIMIT, cutoff_days: DEFAULT_CUTOFF_DAYS)
    entries_between(Date.current - cutoff_days, nil, :desc).first(limit)
  end

  # Dates of +year+ with entries, oldest first, as [[date, [Entry]]].
  def for_year(year)
    entries_between(Date.new(year, 1, 1), Date.new(year, 12, 31), :asc)
  end

  private

  def entries_between(start_date, end_date, date_order)
    return [] if @settings.empty?

    rows = firsts(start_date, end_date).select { |row| enabled?(row) }
    observations = Observation.where(id: rows.pluck("obs_id")).preload(:species, card: :locus).index_by(&:id)

    dates = rows.group_by { |row| row["observ_date"] }.sort_by(&:first)
    dates.reverse! if date_order == :desc
    dates.map do |date, date_rows|
      primaries = date_rows.group_by { |row| row["species_id"] }.values.flat_map { |species_rows| primaries_for(species_rows) }
      [date, merge(primaries, observations)]
    end
  end

  def loci
    @loci ||= Locus.where(id: @settings.filter_map(&:locus_id)).index_by(&:id)
  end

  def enabled?(row)
    setting = @settings.find { |s| s.locus_id == row["scope_id"] }
    setting&.public_send(row["year_scope"] ? :year : :life)
  end

  # A candidate is covered when the species is also added on the same day to
  # a more significant list: a life list of an ancestor area (or of the same
  # area, for a year list), or a year list of an ancestor area.
  def primaries_for(rows)
    candidates = rows.map do |row|
      { locus_id: row["scope_id"], type: row["year_scope"] ? :year : :life, year: row["year_scope"],
        obs_id: row["obs_id"], list_total: row["list_total"], }
    end
    life_ids = candidates.select { |c| c[:type] == :life }.to_set { |c| c[:locus_id] }
    year_ids = candidates.select { |c| c[:type] == :year }.to_set { |c| [c[:locus_id], c[:year]] }

    covered, primaries = candidates.partition do |c|
      ancestors = ancestor_ids(c[:locus_id])
      if c[:type] == :life
        ancestors.any? { |id| life_ids.include?(id) }
      else
        [c[:locus_id], *ancestors].any? { |id| life_ids.include?(id) } ||
          ancestors.any? { |id| year_ids.include?([id, c[:year]]) }
      end
    end
    covered_life = covered.select { |c| c[:type] == :life }

    primaries.map { |c| c.merge(covered: c[:type] == :life ? covered_life : []) }
  end

  def merge(primaries, observations)
    primaries
      .group_by { |p| [p[:type], p[:locus_id], p[:year], p[:covered].map { |c| c[:locus_id] }.sort_by(&:to_i)] }
      .map do |(type, locus_id, year, _), group|
        group = group.sort_by { |p| p[:list_total] }
        covered = group.flat_map { |p| p[:covered] }
          .group_by { |c| c[:locus_id] }
          .map { |id, cs| [loci[id], cs.pluck(:list_total).max] }
          .sort_by { |locus, _| depth(locus.id) }
        Entry.new(type: type, locus: loci[locus_id], year: year,
          observations: group.map { |p| observations[p[:obs_id]] },
          list_total: group.last[:list_total], covered: covered)
      end
      .sort_by { |e| [e.type == :life ? 0 : 1, depth(e.locus&.id), e.year.to_i] }
  end

  # The World (nil) is an ancestor of every area.
  def ancestor_ids(locus_id)
    locus_id ? [nil, *loci[locus_id].ancestor_ids] : []
  end

  def connection
    Observation.connection
  end

  def depth(locus_id)
    ancestor_ids(locus_id).size
  end

  # First observation of each species in each enabled scope (World and areas),
  # ever and per year, with the list size at that moment, for observations in
  # the date range.
  def firsts(start_date, end_date)
    pairs = loci.values.flat_map { |locus| locus.subregion_ids.map { |id| [locus.id, id] } }
    scope_ids = pairs.map { |scope_id, _| Integer(scope_id) }
    locus_ids = pairs.map { |_, locus_id| Integer(locus_id) }
    world = @settings.any? { |s| s.locus_id.nil? }

    base = @observation_scope.identified.joins(:card).select(
      "observations.id AS obs_id, observations.created_at AS obs_created_at, observations.species_id,
      cards.observ_date, cards.locus_id,
      to_timestamp(cards.start_time, 'HH24:MI') AS start_ts,
      EXTRACT(year FROM cards.observ_date)::integer AS obs_year"
    )
    order = "observ_date, start_ts NULLS LAST, obs_id"
    # Matches the numbering of the lifelist (Lifelist::Base::DATE_ORDERING reversed).
    list_order = "observ_date, start_ts NULLS FIRST, obs_created_at NULLS LAST, obs_id"

    sql = <<~SQL.squish
      WITH base AS (#{base.to_sql}),
      scope_loci AS (
        SELECT * FROM unnest(ARRAY[#{scope_ids.join(",")}]::integer[], ARRAY[#{locus_ids.join(",")}]::integer[])
          AS t(scope_id, locus_id)
      ),
      scoped AS (
        #{"SELECT base.*, NULL::integer AS scope_id FROM base UNION ALL" if world}
        SELECT base.*, scope_loci.scope_id FROM base JOIN scope_loci ON scope_loci.locus_id = base.locus_id
      ),
      firsts AS (
        (SELECT DISTINCT ON (species_id, scope_id) *, NULL::integer AS year_scope
          FROM scoped ORDER BY species_id, scope_id, #{order})
        UNION ALL
        (SELECT DISTINCT ON (species_id, scope_id, obs_year) *, obs_year AS year_scope
          FROM scoped ORDER BY species_id, scope_id, obs_year, #{order})
      ),
      counted AS (
        SELECT *, COUNT(*) OVER (PARTITION BY scope_id, year_scope ORDER BY #{list_order}) AS list_total
        FROM firsts
      )
      SELECT obs_id, species_id, observ_date, scope_id, year_scope, list_total
      FROM counted
      WHERE observ_date >= #{connection.quote(start_date)}
        #{"AND observ_date <= #{connection.quote(end_date)}" if end_date}
    SQL

    result = connection.select_all(sql)
    result.cast_values.map { |values| result.columns.zip(Array(values)).to_h }
  end
end
