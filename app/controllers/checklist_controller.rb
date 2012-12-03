class ChecklistController < ApplicationController
  administrative

  def edit
    @locus = Country.find_by_slug!(params[:country])
    if @locus.slug == 'ukraine'
      @checklist = @locus.checklist
    else
      raise ActiveRecord::RecordNotFound, "Checklist not allowed for #{@locus.name_en}"
    end
    @edit = true
    render 'countries/checklist'
  end

  def save
    params[:s].each do |sp|
      item = LocalSpecies.find(sp[:id])
      item.update_attributes!(notes_ru: sp[:n])
    end
    redirect_to action: :edit
  end
end
