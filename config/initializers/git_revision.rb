# TODO: read from repo folder (used by Capistrano3)

begin
  if File.directory?(File.join(Rails.root, ".git"))
    $revision, $commit = `git show -s --format=%H%n%n%B`.split("\n\n", 2)
  else
    revision_file = File.join(Rails.root, "REVISION")
    if File.exist?(revision_file)
      $revision = File.read(revision_file)
      # In repo folder:
      # $commit = `git show -s --format=%B #{$revision}`
    end
  end
rescue
end
