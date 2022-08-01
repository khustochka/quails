# frozen_string_literal: true

class Application3Controller < ApplicationController
  clear_helpers
  helper FacebookSdkHelper
  helper AirbrakeHelper

  before_action do
    prepend_view_path "app/views/app3"
  end
end
