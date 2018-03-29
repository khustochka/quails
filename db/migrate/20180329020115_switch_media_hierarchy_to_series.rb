class SwitchMediaHierarchyToSeries < ActiveRecord::Migration[5.1]
  def change
    Image.where(id: Image.select(:parent_id).distinct).preload(:children).each do |img|
      s = MediaSeries.new
      imgs = img.children.to_a
      imgs.unshift img
      s.media << imgs
      s.save!
    end
  end
end
