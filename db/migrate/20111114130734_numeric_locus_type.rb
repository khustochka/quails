class NumericLocusType < ActiveRecord::Migration
  def up
    add_column :loci, :loc_type_num, :integer
    Locus::TYPES.each_with_index do |type, i|
      Locus.update_all({:loc_type_num => i}, {:loc_type => type})
    end
    remove_column :loci, :loc_type
    rename_column :loci, :loc_type_num, :loc_type
  end

  def down
    add_column :loci, :loc_type_str, :string
    Locus::TYPES.each_with_index do |type, i|
      Locus.update_all({:loc_type_str => type}, {:loc_type => i})
    end
    remove_column :loci, :loc_type
    rename_column :loci, :loc_type_str, :loc_type
  end
end
