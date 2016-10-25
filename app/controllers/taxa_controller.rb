class TaxaController < ApplicationController

  administrative

  # before_action :find_species, only: [:show, :update]

  def index
    #TODO : Filter by order, family, category
    @term = params[:term]
    @taxa = if @term.present?
              Search::TaxonSearchUnweighted.new(Taxon.all, @term).find
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
    obs = Observation.select("taxon_id, COUNT(observations.id) as weight").group(:taxon_id)
    weighted_taxa = Taxon.joins("LEFT OUTER JOIN (#{obs.to_sql}) obs on id = obs.taxon_id")
    @taxa = Search::TaxonSearchWeighted.new(weighted_taxa, term)
    render json: @taxa.find
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
