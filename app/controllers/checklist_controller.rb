# frozen_string_literal: true

class ChecklistController < ApplicationController
  administrative except: [:show]

  def show
    fetch_checklist
    render @country.slug
  end

  def edit
    fetch_checklist
  end

  def save
    LocalSpecies.transaction do
      params[:s].each do |sp|
        LocalSpecies.where(id: sp[:id]).update_all(notes_ru: sp[:n], status: sp[:s], reference: sp[:r])
      end
    end
    # Expire cache manually, because update_all skips callbacks
    Quails::CacheKey.checklist.invalidate
    redirect_to checklist_path(country: params[:country])
  end

  private

  def fetch_checklist
    @country = if params[:country] == "manitoba"
      Locus.find_by!(slug: "manitoba")
    else
      Country.find_by!(slug: params[:country])
    end

    if @country.slug.in? %w(ukraine manitoba)
      @checklist = @country.checklist
    else
      raise ActiveRecord::RecordNotFound, "Checklist not allowed for #{@country.name_en}"
    end
  end
end
