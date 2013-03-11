require "quails/env"

if Rails.env.production? && Quails.env.vps?
  $announcement = "This is a test site."
end
