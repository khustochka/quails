# frozen_string_literal: true

Rails.application.configure do
  config.good_job = {
    smaller_number_is_higher_priority: true,

    # Put cron jobs in config/cron_jobs.yml
    # Note they will not run without setting GOOD_JOB_ENABLE_CRON=true
    cron: config_for(:cron_jobs),
  }
end
