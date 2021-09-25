# frozen_string_literal: true

require "flickr/client"

class SettingsController < ApplicationController
  administrative

  # GET /settings
  def index
  end

  # POST /settings/save
  def save
    params[:s].each do |key, value|
      setting = Settings.where(key: key)
      if setting.present?
        setting.update_all(value: value)
      else
        Settings.create!(key: key, value: value)
      end
    end
    redirect_to :settings, notice: "Setings saved"
  end
end
