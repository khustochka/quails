require 'lib/import/legacy/models/blog'

module Import
  class BlogImport
    extend LegacyInit

    def self.get_posts

      require 'app/models/post'

      init_legacy

      Legacy::Post.all.each do |post|
        Post.create!({
                              :code => post.post_id,
                              :title => conv_to_new(post.post_title),
                              :text => conv_to_new(post.post_text),
                              :topic => post.post_type,
                              :status => post.post_status,
                              :lj_post_id => post.lj_post_id.zero? ? nil : post.lj_post_id,
                              :lj_url_id => post.lj_url_id.zero? ? nil : post.lj_url_id,
                              :face_date => post.post_date,
                              :updated_at => post.post_update
                              })
      end

    end

  end
end