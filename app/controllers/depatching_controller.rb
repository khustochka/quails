# frozen_string_literal: true

class DepatchingController < ApplicationController
  administrative

  def index
    @cards = Card.joins(:observations).where.not(observations: { patch_id: nil }).distinct.order(:observ_date)
  end
end
