class AddThumbnalToEveryVideo < ActiveRecord::Migration[4.2]
  def change
    Video.all.each do |v|
      v.send(:update_thumbnail)
      v.save
    end
  end
end
