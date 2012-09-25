class BooksController < ApplicationController

  respond_to :json, only: [:save_order]

  administrative

  find_record by: :slug, before: [:show, :edit, :update, :destroy]

  # GET /books
  def index
    @books = Book.scoped
  end

  # GET /books/1
  def show
    @species = @book.book_species.preload(:species).extend(SpeciesArray)
  end

  # GET /books/new
  def new
    @book = Book.new
    render :form
  end

  # GET /books/1/edit
  def edit
    render :form
  end

  # POST /books
  def create
    @book = Book.new(params[:book])
    if @book.save
      redirect_to(@book, :notice => 'Book was successfully created.')
    else
      render :form
    end
  end

  # PUT /books/1
  def update
    if @book.update_attributes(params[:book])
      redirect_to(@book, :notice => 'Book was successfully updated.')
    else
      render :form
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy
    #TODO: rescue ActiveRecord::DeleteRestrictionError showing a notice and later - options for substitution
    redirect_to(books_url)
  end
end
