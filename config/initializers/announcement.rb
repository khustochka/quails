#if Rails.env.production?
#  $announcement = <<-CDATA
#    ...
#  CDATA
#end

begin
  $revision, $commit = `git log -n 1 --format="%H%n%n%B"`.split("\n\n", 2)
rescue
end
