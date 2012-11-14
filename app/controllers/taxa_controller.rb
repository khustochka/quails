class TaxaController < ApplicationController

  administrative

  before_filter :find_species, only: [:show, :update]

  def show
    render :form
  end

  def update
    if @taxon.update_attributes(params[:taxon])
      redirect_to([@book, @taxon], :notice => 'Taxon was successfully updated.')
    else
      render :form
    end
  end

  private
  def find_species
    @book = Book.find_by_slug(params[:book_id])
    @taxon = Taxon.find_by_name_sci!(params[:id].sp_humanize)
  end
end
