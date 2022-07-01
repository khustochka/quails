# frozen_string_literal: true

module Quails
  class Revision < Struct.new(:sha, :message, keyword_init: true)
    def self.get
      Rails.cache.fetch(rev_cache_key) do
        read_revision
      end
    end

    private

    def self.rev_cache_key
      @rev_cache_key ||= "quails_revision_#{Quails.unique_key}"
    end

    def self.read_revision
      unless Rails.env.test?
        begin
          sha = message = nil
          revision_file = File.join(Rails.root, "REVISION")
          rev = ENV["GIT_REVISION"] || (File.exist?(revision_file) && File.read(revision_file))
          if rev&.match?(/\A\h{40}\Z/) || rev&.match?(/\A\h{8}\Z/)
            sha = rev.strip
            repo_folder = File.join(Rails.root, "../../repo")
            if File.directory?(repo_folder)
              message = Dir.chdir(repo_folder) do
                `git show -s --format=%B #{sha}`
              end
            end
          elsif File.directory?(File.join(Rails.root, ".git"))
            sha, message = `git show -s --format=%H%n%n%B`.split("\n\n", 2)
          end
          if sha
            self.new(sha: sha, message: message)
          end
        rescue
        end
      end
    end
  end
end
