namespace :assets do
  namespace :precompile do
    require 'sass/plugin'
    Sass::Plugin.update_stylesheets
  end
end