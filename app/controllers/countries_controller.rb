# frozen_string_literal: true

class CountriesController < ApplicationController
  GALLERY_THUMBNAILS = {
    "ukraine" => "https://bwua-static.s3.eu-central-1.amazonaws.com/cuckoo-thumb.jpg",
  }.freeze

  localized only: [:gallery]

  def gallery
    @country = Country.find_by!(slug: params[:country])

    @thumbs = @country.checklist([:image])
  end
end
