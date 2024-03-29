# frozen_string_literal: true

module ErrorReporterHelper
  def airbrake_config_meta_tag
    if Airbrake.configured?
      tag.meta(name: "airbrake-config",
        content: [
          Airbrake::Config.instance.host.sub(%r{^https?://}, ""),
          Airbrake::Config.instance.project_key,
          Airbrake::Config.instance.project_id,
        ].join(":"))
    end
  end

  def honeybadger_config_meta_tag
    key = Honeybadger::Agent.instance.config.env[:api_key]
    if key.present?
      tag.meta(name: "honeybadger-api-key",
        content: key)
    end
  end
end
