# frozen_string_literal: true

require "flickr/client"

class SettingsController < ApplicationController
  administrative

  # GET /settings
  def index
  end

  # POST /settings/save
  def save
    settings = Settings.all.index_by(&:key)
    # Parameters -> HashWithIndifferentAccess -> Hash
    params[:s].to_h.to_hash.each do |key, value|
      setting = settings[key.to_s]
      if setting.present?
        setting.update(value: value)
      else
        Settings.create!(key: key, value: value)
      end
    end
    redirect_to :settings, notice: "Settings saved"
  end
end
