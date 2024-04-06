# frozen_string_literal: true

module Quails
  class Revision < Struct.new(:sha, :message, keyword_init: true)
    class << self
      def get
        Rails.cache.fetch(rev_cache_key) do
          read_revision
        end
      end

      private

      def rev_cache_key
        @rev_cache_key ||= "quails_revision_#{Quails.config.unique_key}"
      end

      def read_revision
        unless Rails.env.test?
          suppress RuntimeError do
            sha = message = nil
            revision_file = Rails.root.join("REVISION")
            rev = ENV["GIT_REVISION"] || (File.exist?(revision_file).presence && File.read(revision_file))
            if rev&.match?(/\A\h{40}\Z/) || rev&.match?(/\A\h{8}\Z/)
              sha = rev.strip
              repo_folder = Rails.root.join("../../repo")
              if File.directory?(repo_folder)
                message = Dir.chdir(repo_folder) do
                  `git show -s --format=%B #{sha}`
                end
              end
            elsif Rails.root.join(".git").directory?
              sha, message = `git show -s --format=%H%n%n%B`.split("\n\n", 2)
            end
            if sha
              new(sha: sha, message: message)
            end
          end
        end
      end
    end
  end
end
