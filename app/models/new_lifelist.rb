class NewLifelist

  include NewLifelist::RelationBuilder

  def self.over(options)
    new(options)
  end

  def self.full
    new({})
  end

  def initialize(options = {})
    @filter = options
  end

  def set_posts_scope(posts_scope)
    @posts_scope = posts_scope
    self
  end

  def sort(sorting)
    @sorting = sorting
    self
  end

  delegate :size, :blank?, to: :to_a

  # def total_count
  #   base.count("DISTINCT species_id")
  # end

  def to_a
    @records ||= get_records
  end

  def locus
    @locus ||= if @filter[:locus]
                 Locus.find_by_slug(@filter[:locus])
               else
                 nil
               end
  end

  def years
    [nil] + MyObservation.filter(normalized_filter.merge({year: nil})).years
  end

  private

  def get_records
    records = relation.to_a
    preload_posts(records)
    records
  end

  def relation
    @relation ||= build_relation.order(ordering)
  end

  def base
    MyObservation.filter(normalized_filter).joins(:card)
  end

  def ordering
    if @sorting == "class"
      "index_num ASC"
    else
      "observ_date DESC, to_timestamp(start_time, 'HH24:MI') DESC NULLS LAST"
    end
  end

  def normalized_filter
    @normalized_filter ||= @filter.dup.tap do |filter|
      if filter[:locus]
        filter[:locus] = Locus.find_by!(slug: filter[:locus]).subregion_ids
      end
    end
  end

end
