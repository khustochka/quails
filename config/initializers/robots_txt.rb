# # Rename restrictive robots.txt if this is REAL production
# # FIXME: maybe this should be done in capistrano?
# if Rails.env.production? && Quails.env.real_prod?
#   FileUtils.mv('public/robots.txt', 'public/robots.txt.disallow',) if File.exist?('public/robots.txt')
# end
