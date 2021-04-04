# frozen_string_literal: true

if Rails.env.production?
  begin
    revision_file = File.join(Rails.root, "REVISION")
    if File.exist?(revision_file)
      rev = File.read(revision_file)
      if rev =~ /\A\h{40}\Z/
        Rails.application.config.x.revision.sha = rev.strip
      end
      repo_folder = File.join(Rails.root, "../../repo")
      if File.directory?(repo_folder)
        Dir.chdir(repo_folder) do
          Rails.application.config.x.revision.message = `git show -s --format=%B #{$revision}`
        end
      end
    elsif File.directory?(File.join(Rails.root, ".git"))
      sha, message = `git show -s --format=%H%n%n%B`.split("\n\n", 2)
      Rails.application.config.x.revision.sha = sha
      Rails.application.config.x.revision.message = message
    end
  rescue
  end
end
