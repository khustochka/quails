# frozen_string_literal: true

class ChecklistController < ApplicationController
  administrative except: [:show]
  localized only: [:show]

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
    unless params[:country].in? %w(ukraine manitoba)
      raise ActiveRecord::RecordNotFound, "Checklist not allowed for #{params[:country]}"
    end

    @country =
      if params[:country] == "manitoba"
        Locus.find_by(slug: "manitoba")
      else
        Country.find_by(slug: params[:country])
      end || PlaceholderCountry.new(params[:country])

    @checklist = @country.checklist
  end
end
