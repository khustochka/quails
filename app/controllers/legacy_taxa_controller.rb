# frozen_string_literal: true

class LegacyTaxaController < ApplicationController

  administrative

  before_action :find_species, only: [:show, :update]

  def show
    render :form
  end

  def update
    if @taxon.update(params[:taxon])
      redirect_to([@book, @taxon], :notice => 'Taxon was successfully updated.')
    else
      render :form
    end
  end

  private
  def find_species
    @book = Book.find_by!(slug: params[:book_id])
    @taxon = @book.legacy_taxa.find(params[:id])
  end
end
