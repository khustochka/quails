class ChecklistNotesText < ActiveRecord::Migration[4.2]
  def up
    %w(notes_ru notes_en notes_uk).each do |col|
      change_column :local_species, col, :text
    end
  end

  def down
  end
end
