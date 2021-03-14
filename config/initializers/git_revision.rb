# frozen_string_literal: true

if Rails.env.production?
  begin
    revision_file = File.join(Rails.root, "REVISION")
    if File.exist?(revision_file)
      rev = File.read(revision_file)
      if rev =~ /\A\h{40}\Z/
        $revision = rev.strip
      end
      repo_folder = File.join(Rails.root, "../../repo")
      if File.directory?(repo_folder)
        Dir.chdir(repo_folder) do
          $commit = `git show -s --format=%B #{$revision}`
        end
      end
    elsif File.directory?(File.join(Rails.root, ".git"))
      $revision, $commit = `git show -s --format=%H%n%n%B`.split("\n\n", 2)
    end
  rescue
  end
end

# FIXME: used by instant articles development feed
$restart_time = Time.now
