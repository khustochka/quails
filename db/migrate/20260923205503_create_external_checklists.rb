# frozen_string_literal: true

class CreateExternalChecklists < ActiveRecord::Migration[8.1]
  def change
    create_table :external_checklists do |t|
      t.string :external_id, null: false, index: { unique: true }
      t.string :time
      t.string :location
      t.string :county
      t.string :state_prov
      t.references :locus, foreign_key: { on_delete: :nullify }
      t.string :status, null: false, default: "pending"
      t.text :error
      t.timestamps
    end
  end
end
