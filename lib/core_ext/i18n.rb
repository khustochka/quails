# frozen_string_literal: true

require "core_ext/i18n/config"

module I18n
  extend(Module.new {
  # Write methods which delegates to the configuration object
  %w(default_locale? russian_locale?).each do |method|
    module_eval <<-DELEGATORS, __FILE__, __LINE__ + 1
        def #{method}
          config.#{method}
        end
    DELEGATORS
  end
  })

end
