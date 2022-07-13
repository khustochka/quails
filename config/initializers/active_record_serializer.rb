# frozen_string_literal: true

Rails.application.configure do
  # FIXME: allow temporarily
  config.active_record.use_yaml_unsafe_load = true
end
