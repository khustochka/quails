class BlobsController < ApplicationController

  administrative

  def create
    uploaded_io = params[:stored_image]
    blob = ActiveStorage::Blob.create_and_upload!(io: uploaded_io, filename: uploaded_io.original_filename, key: uploaded_io.original_filename)
    blob.analyze_later
    redirect_to blob_url(blob.signed_id)
  end

  def show
    blob = ActiveStorage::Blob.find_signed!(params[:id])
    render json: blob.as_json(only: [:filename, :metadata], methods: [:signed_id]).merge(
          {src: rails_blob_url(blob), url: blob_url(blob.signed_id)}
      )
  end

end
