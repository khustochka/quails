# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

app_assets_path = Rails.root.join('app', 'assets').to_path

Rails.application.config.assets.precompile << Proc.new { |path|
  if path == 'html5.js' || path =~ /\.png$/
    true
  elsif path =~ /\.(css|js)\z/
    full_path = Rails.application.assets.resolve(path)
    # return true to compile asset, false to skip
    full_path.starts_with?(app_assets_path)
  else
    false
  end
}
