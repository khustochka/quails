class BookSpeciesController < ApplicationController

  administrative

  before_filter :find_species

  def show
    render :form
  end

  def new
    @book = Book.find_by_slug(params[:book_id])
    @species = @book.species.new
    render :form.species.new
  end

  def create
    @book = Book.find_by_slug(params[:book_id])
    if @species = @book.species.create(params[:book_species])
      redirect_to([@book, @species], :notice => 'BookSpecies was successfully created.')
    else
      render :form
    end
  end

  def update
    if @species.update_attributes(params[:book_species])
      redirect_to([@book, @species], :notice => 'BookSpecies was successfully updated.')
    else
      render :form
    end
  end

  private
  def find_species
    @book = Book.find_by_slug(params[:book_id])
    @species = BookSpecies.find_by_name_sci!(params[:id].sp_humanize)
  end
end
