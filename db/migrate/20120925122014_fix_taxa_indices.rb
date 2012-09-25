class FixTaxaIndices < ActiveRecord::Migration
  def up
    remove_index "taxa", :name => "index_book_species_on_authority_id"
    remove_index "taxa", :name => "index_book_species_on_index_num"
    remove_index "taxa",:name => "index_book_species_on_name_sci"

    add_index "taxa", ["book_id", "index_num"]
    add_index "taxa", ["book_id", "name_sci"]
  end

  def down
  end
end
