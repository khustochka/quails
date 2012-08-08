class SettingsController < ApplicationController

  administrative

  # GET /settings
  def index
    @settings = Settings.to_hash
  end

  # POST /settings/save
  def save
    request.request_parameters.except(:utf8, :authenticity_token).each do |key, value|
      setting = Settings.where(key: key)
      if setting.any?
        setting.update_all(value: value)
      else
        Settings.create!(key: key, value: value)
      end
    end
    redirect_to :settings, :notice => "Setings saved"
  end

end
