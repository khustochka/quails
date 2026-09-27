# frozen_string_literal: true

class AddUrlToExternalChecklists < ActiveRecord::Migration[8.1]
  def change
    add_column :external_checklists, :url, :string
  end
end
