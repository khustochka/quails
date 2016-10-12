class TaxaController < ApplicationController

  administrative

  # before_action :find_species, only: [:show, :update]

  def index
    #TODO : Filter by order, family, category
    @term = params[:term]
    @taxa = if @term.present?
                 Taxon.search_by_term(@term).limit(50)
               else
                 Taxon.order(:index_num).page(params[:page]).per(50)
            end
    @taxa = @taxa.preload(:species)
    if request.xhr?
      render partial: "taxa/table", layout: false
    else
      render
    end
  end

  def search
    term = params[:term]
    @taxa = Taxon.search_by_term(term).limit(30)
    taxa_arr = @taxa.map do |tx|
      {
          value: tx.name_sci,
          label: [tx.name_sci, tx.name_en].join(" - "),
          cat: tx.category,
          id: tx.id
      }
    end
    render json: taxa_arr
  end

  def show
    @taxon = Taxon.find_by_ebird_code(params[:id])
    render :form
  end

  def edit
    @taxon = Taxon.find_by_ebird_code(params[:id])
    render :form
  end

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
