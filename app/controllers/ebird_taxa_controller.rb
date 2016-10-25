class EbirdTaxaController < ApplicationController

  administrative

  # before_action :find_species, only: [:show, :update]

  def index
    #TODO : Filter by order, family, category
    @term = params[:term]
    @taxa = if @term.present?
              Search::EbirdTaxonSearchUnweighted.new(EbirdTaxon.all, @term).find
            else
              EbirdTaxon.order(:index_num).page(params[:page]).per(50)
            end
    @taxa = @taxa.preload(:taxon => :species)
    if request.xhr?
      render partial: "ebird_taxa/table", layout: false
    else
      render
    end
  end

  def show
    @taxon = EbirdTaxon.find_by_ebird_code(params[:id])
  end

end
