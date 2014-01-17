ALL_LOCALES = [:en, :ru, :uk]
DEFAULT_PUBLIC_LOCALE = :ru

I18n.available_locales = ALL_LOCALES

$localedisabled = false




# Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
# Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
Rails.application.config.time_zone = 'Kyiv'
# THIS APP SPECIFIC NOTE: if you ever have to change the time zone take into account that 'posts.facedate'
# is not a timezone dependent timestamp but rather a carved in stone time and should be shown the same to everyone
# so you'll have to convert it in the DB

# The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
Rails.application.config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '{en,ru,uk}','*.{rb,yml}').to_s]
Rails.application.config.i18n.default_locale = :ru

# Configure the default encoding used in templates for Ruby 1.9.
Rails.application.config.encoding = "utf-8"
