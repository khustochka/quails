class MoveLJData < ActiveRecord::Migration[4.2]
  def change
    Post.where("lj_post_id IS NOT NULL").each do |post|
      post.lj_data.post_id = post.lj_post_id
      post.lj_data.url = "http://stonechat.livejournal.com/#{post.lj_url_id}.html"
      post.save!
    end
  end
end
