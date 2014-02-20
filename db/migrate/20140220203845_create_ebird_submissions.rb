class CreateEbirdSubmissions < ActiveRecord::Migration
  def change
    create_table :ebird_submissions do |t|
      t.integer :ebird_file_id, null: false
      t.integer :card_id, null: false
    end
  end
end
