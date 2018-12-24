class EbirdFixController < ApplicationController

  administrative

  class GoodChecklist
    include Mongoid::Document
    store_in collection: "observations"
    field :checklistId, type: String
    field :comment, type: String
    field :country, type: String
    field :location, type: String
    field :date, type: Date
  end

  class ChecklistState
    include Mongoid::Document
    field :checklistId, type: String
    field :state, type: String
  end

  def index
    @checklists = GoodChecklist.where(comment: /photo\.gne/).where(:country.not => /^(US|GB)-/).where(:date.lt => "2017-01-01").map do |k|
      [k.date, k.checklistId, k.country, k.location]
    end.uniq.sort_by(&:first)
    @states = ChecklistState.all.index_by(&:checklistId)
  end

  def update
    state = ChecklistState.where(checklistId: params[:id]).first
    unless state
      state = ChecklistState.new(checklistId: params[:id])
    end
    state.state = params[:state]
    state.save
    render json: {state: state.state}
  end

end
