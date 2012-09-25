class TaxaController < ApplicationController

  administrative

  before_filter :find_species

  def show
    render :form
  end

  def new
    @book = Book.find_by_slug(params[:book_id])
    @taxon = @book.species.new
    render :form.species.new
  end

  def create
    @book = Book.find_by_slug(params[:book_id])
    if @taxon = @book.species.create(params[:taxa])
      redirect_to([@book, @taxon], :notice => 'BookSpecies was successfully created.')
    else
      render :form
    end
  end

  def update
    if @taxon.update_attributes(params[:taxa])
      redirect_to([@book, @taxon], :notice => 'BookSpecies was successfully updated.')
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
