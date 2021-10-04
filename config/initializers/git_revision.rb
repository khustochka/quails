# frozen_string_literal: true

unless Rails.env.test?
  begin
    revision_file = File.join(Rails.root, "REVISION")
    if File.exist?(revision_file)
      rev = File.read(revision_file)
      if rev.match?(/\A\h{40}\Z/)
        sha = rev.strip
        repo_folder = File.join(Rails.root, "../../repo")
        if File.directory?(repo_folder)
          message = Dir.chdir(repo_folder) do
            `git show -s --format=%B #{sha}`
          end
        end
      end
    elsif File.directory?(File.join(Rails.root, ".git"))
      sha, message = `git show -s --format=%H%n%n%B`.split("\n\n", 2)
    end
    if sha && message
      Rails.application.config.x.revision.sha = sha
      Rails.application.config.x.revision.message = message
    end
  rescue
  end
end
