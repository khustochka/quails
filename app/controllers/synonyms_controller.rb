class SynonymsController < ApplicationController

  administrative

  def index
    @synonyms = UrlSynonym.order(:name_sci).preload(:species)
  end


  def update
    @synonym = UrlSynonym.find(params[:id])
    @synonym.update_attributes(params[:url_synonym])
  end

end