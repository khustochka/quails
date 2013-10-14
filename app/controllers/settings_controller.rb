require 'flickr_app'

class SettingsController < ApplicationController

  administrative

  # GET /settings
  def index
  end

  # POST /settings/save
  def save
    params[:s].each do |key, value|
      setting = Settings.where(key: key)
      if setting.any?
        setting.update_all(value: Settings.serialized_attributes['value'].dump(value))
      else
        Settings.create!(key: key, value: value)
      end
    end
    FlickrApp.expire!
    redirect_to :settings, :notice => "Setings saved"
  end

end
