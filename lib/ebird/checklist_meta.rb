# frozen_string_literal: true

module EBird
  class ChecklistMeta
    # Represents imported checklist row
    include ActiveModel::Model

    attr_accessor :ebird_id, :time, :location, :county, :state_prov, :card

    def locus_id
      Locus.find_by(name_en: location)&.id
    end

    def parent_id
      Locus.find_by(name_en: (county || state_prov))&.id
    end
  end
end
