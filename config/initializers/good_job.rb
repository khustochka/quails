# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    smaller_number_is_higher_priority: true,
    cron: config_for(:cron_jobs),
  }
end
