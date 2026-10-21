# frozen_string_literal: true

class CreateLogbookSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :logbook_settings do |t|
      t.references :locus, foreign_key: { on_delete: :cascade }, index: { unique: true, nulls_not_distinct: true }
      t.boolean :life, null: false, default: false
      t.boolean :year, null: false, default: false
    end
  end
end
