# frozen_string_literal: true

class MediaSeries < ApplicationRecord

  has_many :media

  default_scope -> { preload(:media => [{:taxa => :species}, :cards]) }

  def date
    media.first.observ_date
  end

end
