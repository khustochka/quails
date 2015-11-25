class EbirdTaxaController < ApplicationController

  administrative

  def index
    #TODO : Filter by order, family, category
    @ebird_taxa = EbirdTaxon.order(:index_num).page(params[:page]).per(50)
  end

end
