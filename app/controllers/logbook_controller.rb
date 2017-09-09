class LogbookController < ApplicationController

  administrative

  def app
    @card = if params[:id]
              Card.find(params[:id])
            else
              Card.new
            end
    @card_props = @card.as_json(
        root: true,
        include: {
            observations: {
                include: {
                    taxon: {only: [:id, :name_sci, :name_en]},
                    post: {only: [:id, :title, :face_date]}
                }
            },
            locus: {only: [:id, :name_en]},
            post: {only: [:id, :title, :face_date]}
        })
  end

end
