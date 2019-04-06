class FixTaxaIndices < ActiveRecord::Migration[4.2]
  def up
    remove_index "taxa", :name => "index_taxa_on_book_id"
    remove_index "taxa", :name => "index_taxa_on_index_num"
    remove_index "taxa",:name => "index_taxa_on_name_sci"

    add_index "taxa", ["book_id", "index_num"]
    add_index "taxa", ["book_id", "name_sci"]
  end

  def down
  end
end
