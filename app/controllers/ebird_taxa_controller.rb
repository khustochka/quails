# frozen_string_literal: true

class EbirdTaxaController < ApplicationController
  administrative

  # before_action :find_species, only: [:show, :update]

  def index
    # TODO : Filter by order, family, category
    @term = params[:term]
    @taxa = if @term.present?
      Search::EbirdTaxonSearchUnweighted.new(EbirdTaxon.all, @term).find
    else
      EbirdTaxon.order(:index_num).page(params[:page]).per(50)
    end
    @taxa = @taxa.preload(taxon: :species)
    if request.xhr?
      render partial: "ebird_taxa/table", layout: false
    else
      render
    end
  end

  def show
    @taxon = EbirdTaxon.find_by(ebird_code: params[:id])
  end

  def promote
    @taxon = EbirdTaxon.find_by(ebird_code: params[:id])
    @taxon.promote
    redirect_to ebird_taxon_path(@taxon)
  end
end
