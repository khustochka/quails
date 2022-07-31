# frozen_string_literal: true

module AirbrakeHelper
  def airbrake_config_meta_tag
    if Airbrake.configured?
      tag(
        "meta",
        name: "airbrake-config",
        content: [
          Airbrake::Config.instance.host.sub(%r{^https?://}, ""),
          Airbrake::Config.instance.project_key,
          Airbrake::Config.instance.project_id,
        ].join(":")
      )
    end
  end
end
