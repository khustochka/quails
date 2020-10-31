# frozen_string_literal: true

require "seeds/seeds"

desc "Tasks for managing DB seed"
namespace :seed do
  desc "Backup the seed"
  task backup: [:environment] do
    Seeds.dump_all
  end
end
