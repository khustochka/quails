#if Rails.env.production?
#  $announcement = <<-CDATA
#    ...
#  CDATA
#end

begin
  if File.directory?(File.join(Rails.root, ".git"))
    $revision, $commit = `git log -n 1 --format="%H%n%n%B"`.split("\n\n", 2)
  end
rescue
end
