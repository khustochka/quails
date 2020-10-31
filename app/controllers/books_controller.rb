# frozen_string_literal: true

class BooksController < ApplicationController

  administrative

  find_record by: :slug, before: [:show, :edit, :update, :destroy]

  # GET /books
  def index
    @books = Book.all
  end

  # GET /books/1
  def show
    @taxa = @book.legacy_taxa.preload(:legacy_species).extend(SpeciesArray)
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
      redirect_to(@book, notice: "Book was successfully created.")
    else
      render :form
    end
  end

  # PUT /books/1
  def update
    if @book.update(params[:book])
      redirect_to(@book, notice: "Book was successfully updated.")
    else
      render :form
    end
  end

  # DELETE /books/1
  def destroy
    @book.destroy
    redirect_to(books_url)
  end
end
