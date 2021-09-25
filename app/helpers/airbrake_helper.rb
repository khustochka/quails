# frozen_string_literal: true
module AirbrakeHelper
  def airbrake_config_meta_tag
    if ENV["AIRBRAKE_API_KEY"] && ENV["AIRBRAKE_HOST"]
      tag("meta", name: "airbrake-config", content: [ENV["AIRBRAKE_HOST"], ENV["AIRBRAKE_API_KEY"], ENV["AIRBRAKE_PROJECT_ID"]].join(":"))
    end
  end
end
