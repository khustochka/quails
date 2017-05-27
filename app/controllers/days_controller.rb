class DaysController < ApplicationController

  administrative

  def index
    @days = Card.select("DISTINCT observ_date").order(:observ_date => :desc).page(params[:page])
  end

  def show
    @day = Day.new(params[:id])
  end

end
