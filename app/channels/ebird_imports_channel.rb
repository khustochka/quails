# frozen_string_literal: true

class EBirdImportsChannel < ApplicationCable::Channel
  def subscribed
    reject unless current_user == "admin"
    stream_for :ebird_imports
  end
end
