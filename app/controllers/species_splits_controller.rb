# frozen_string_literal: true

class SpeciesSplitsController < ApplicationController

  administrative

  def index
    @splits = SpeciesSplit.joins(:superspecies).order("species.name_sci").preload(:superspecies, :subspecies)
  end

end
