# frozen_string_literal: true

class PagesController < ApplicationController
  include HighVoltage::StaticPage

  # Regular `localized` does not work, because of the same action
  before_action only: [:show] do
    @localized = true
    @all_locales = case params[:id]
    when "winter" then [:uk]
    when "links" then [:uk]
    when "about" then [:en, :uk]
    else [:en, :uk]
    end
  end
end
