class ChecklistController < ApplicationController
  administrative

  def save
    params[:s].each do |sp|
      item = LocalSpecies.find(sp[:id])
      item.update_attributes!(notes_ru: sp[:n], status: sp[:s])
    end
    redirect_to checklist_path(country: params[:country])
  end
end
