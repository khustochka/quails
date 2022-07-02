# frozen_string_literal: true

class TaxaController < ApplicationController
  administrative

  # before_action :find_species, only: [:show, :update]

  def index
    # TODO : Filter by order, family, category
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
    @taxa = Search::TaxonSearchWeighted.new(Taxon.weighted_by_abundance, term)
    render json: @taxa.find
  end

  def show
    @taxon = Taxon.find_by(ebird_code: params[:id])
    render :form
  end

  # def edit
  #   @taxon = Taxon.find_by_ebird_code(params[:id])
  #   render :form
  # end
  #
  # def update
  #   if @taxon.update(params[:taxon])
  #     redirect_to(@taxon, :notice => 'Taxon was successfully updated.')
  #   else
  #     render :form
  #   end
  # end
end
