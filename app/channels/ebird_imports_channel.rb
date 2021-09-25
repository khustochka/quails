# frozen_string_literal: true

class EbirdImportsChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user == "admin"
    stream_for :ebird_imports
  end
end
