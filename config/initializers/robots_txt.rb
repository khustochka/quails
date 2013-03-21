require "quails/env"

# Rename restrictive robots.txt if this is REAL production
if Rails.env.production? && Quails.env.real_prod?
  FileUtils.mv('public/robots.txt', 'public/robots.txt.disallow',) if File.exists?('public/robots.txt')
end
