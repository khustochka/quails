class ConvertLjDataToStruct < ActiveRecord::Migration
  def up
    rename_column :posts, :lj_data, :lj_data_old
    add_column :posts, :lj_data, :text

    Post.serialize :lj_data_old, Hashie::Mash

    Post.where('lj_data_old IS NOT NULL').each do |post|
      data = post.lj_data_old
      post.lj_data = Post::LJData.new(data.post_id, data.url)
      post.save!
    end

    remove_column :posts, :lj_data_old

  end

  def down

  end
end
