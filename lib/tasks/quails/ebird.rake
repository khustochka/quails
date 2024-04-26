# frozen_string_literal: true

namespace :quails do
  namespace :ebird do
    desc "Preload eBird checklists"
    task checklists_preload: :environment do
      require "ebird/service"

      EBird::Service.preload_checklists
    end
  end
end
