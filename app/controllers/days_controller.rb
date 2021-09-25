# frozen_string_literal: true

class DaysController < ApplicationController
  administrative

  def index
    @days = Card.select("DISTINCT observ_date").order(observ_date: :desc).page(params[:page])
  end

  def show
    date = Date.parse(params[:id])
    @day = Day.new(date)
  end
end
