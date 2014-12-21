class AddThumbnalToEveryVideo < ActiveRecord::Migration
  def change
    Video.all.each do |v|
      v.send(:update_thumbnail)
      v.save
    end
  end
end
