# encoding: utf-8

module Legacy
  module Import
    class Posts

      def self.import_posts(posts)
        puts 'Importing blog posts...'
        posts.each do |post|
          Post.create!({
                           :code => post[:post_id],
                           :title => Legacy::Utils.conv_to_new(post[:post_title]).gsub(' - ', '&nbsp;— '),
                           :text => Legacy::Utils.conv_to_new(post[:post_text]).gsub(' - ', '&nbsp;— '),
                           :topic => post[:post_type],
                           :status => post[:post_status],
                           :lj_post_id => post[:lj_post_id].to_i.zero? ? nil :  post[:lj_post_id],
                           :lj_url_id => post[:lj_url_id].to_i.zero? ? nil : post[:lj_url_id],
                           :face_date => post[:post_date],
                           :updated_at => post[:post_update]
                       })
        end
        puts 'Done.'
      end

    end
  end
end