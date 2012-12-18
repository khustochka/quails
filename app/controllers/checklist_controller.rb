class ChecklistController < ApplicationController
  administrative except: [:show]

  def show
    fetch_checklist
    render @country.slug
  end

  def edit
    fetch_checklist
    @edit = true
    render @country.slug
  end

  def save
    LocalSpecies.transaction do
      params[:s].each do |sp|
        LocalSpecies.where(id: sp[:id]).update_all(notes_ru: sp[:n], status: sp[:s], reference: sp[:r])
      end
    end
    redirect_to checklist_path(country: params[:country])
  end

  private
  def fetch_checklist
    @country = Country.find_by_slug!(params[:country])
    if @country.slug == 'ukraine'
      @checklist = @country.checklist
    else
      raise ActiveRecord::RecordNotFound, "Checklist not allowed for #{@country.name_en}"
    end
  end
end
