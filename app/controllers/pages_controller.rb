# frozen_string_literal: true

class PagesController < ApplicationController
  include HighVoltage::StaticPage

  # Regular `localized` does not work, because of the same action
  before_action only: [:show] do
    @localized = true
    @all_locales = case params[:id]
    when "winter" then Quails.enabled_locales - [:en]
    when "links" then Quails.enabled_locales - [:en]
    when "about" then Quails.enabled_locales
    else Quails.enabled_locales
    end
  end
end
