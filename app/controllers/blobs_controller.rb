# frozen_string_literal: true

class BlobsController < ApplicationController
  administrative

  def show
    blob = ActiveStorage::Blob.find_signed!(params[:id])
    render json: blob.as_json(only: [:filename, :metadata], methods: [:signed_id]).merge(
      { src: rails_blob_url(blob), url: blob_url(blob.signed_id) }
    )
  end

  def create
    uploaded_io = params[:stored_image]
    name1, ext = uploaded_io.original_filename.split(/\.([^.]*)\Z/)
    new_key = "%s-%s.%s" % [name1, SecureRandom.base36(12), ext]
    blob = ActiveStorage::Blob.create_and_upload!(io: uploaded_io, filename: uploaded_io.original_filename, key: new_key)
    blob.analyze_later
    redirect_to blob_url(blob.signed_id)
  end
end
