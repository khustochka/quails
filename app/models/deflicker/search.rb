# frozen_string_literal: true

module Deflicker
  class Search

    include ActiveModel::Model
    include ActiveModel::Attributes

    attribute :public, :boolean
    attribute :removed, :boolean, default: false
    attribute :on_site, :boolean
    attribute :with_journal_entries, :boolean

    def self.model_name
      ActiveModel::Name.new(self, nil, "Q")
    end

    def persisted?
      false
    end

    def result
      base = Flicker.where(removed: removed)
      unless public.nil?
        base = base.where(public: public)
      end
      unless on_site.nil?
        condition = on_site ? {:slug.ne => nil} : {:slug => nil}
        base = base.where(condition)
      end
      unless with_journal_entries.nil?
        base = base.where("journal_entry_ids.0" => {"$exists" => with_journal_entries})
      end
      base
    end

  end
end
