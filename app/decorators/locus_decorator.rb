# frozen_string_literal: true

class LocusDecorator < ModelDecorator

  def full_name
    tail = [@model.cached_city, @model.cached_subdivision, @model.cached_country].
        compact.uniq.map(&:name).join(", ")
    [self_and_parent, tail].map(&:presence).compact.join(", ")
  end

  def short_full_name
    tail = [@model.cached_city, @model.cached_subdivision].
        compact.uniq.map(&:name).join(", ")
    [self_and_parent, tail].map(&:presence).compact.join(", ")
  end

  private

  def self_and_parent
    if @model.patch
      [@model.cached_parent, @model].compact.uniq.map(&:name).join(" - ")
    else
      [@model, @model.cached_parent].compact.uniq.map(&:name).join(", ")
    end
  end
end
