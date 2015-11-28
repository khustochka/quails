class TaxaController < ApplicationController

  administrative

  # before_action :find_species, only: [:show, :update]

  def index
    #TODO : Filter by order, family, category
    @taxa = Taxon.order(:index_num).page(params[:page]).per(50)
  end

  def search
    term = params[:term]
    @taxa = Taxon.search_by_term(term).limit(30)
    taxa_arr = @taxa.map do |tx|
      {
          value: tx.name_sci,
          label: [tx.name_sci, tx.name_en].join(" - "),
          id: tx.id
      }
    end
    render json: taxa_arr
  end

  # def show
  #   render :form
  # end
  #
  # def update
  #   if @taxon.update_attributes(params[:taxon])
  #     redirect_to([@book, @taxon], :notice => 'Taxon was successfully updated.')
  #   else
  #     render :form
  #   end
  # end
  #
  # private
  # def find_species
  #   @book = Book.find_by!(slug: params[:book_id])
  #   @taxon = @book.taxa.find_by!(name_sci: Taxon.humanize(params[:id]))
  # end
end
