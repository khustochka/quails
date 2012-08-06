# encoding: utf-8

require 'bunch_db/table'

module Legacy
  module Import
    module Posts

      def self.import_posts(posts)
        puts 'Importing blog posts...'
        table = BunchDB::Table.new('posts')
        column_names = Post.column_names.reject { |e| e == 'id' }
        records = posts.map do |post|
          rec = HashWithIndifferentAccess.new(
              slug: post[:post_id],
              title: post[:post_title],
              text: post[:post_text],
              topic: post[:post_type],
              status: post[:post_status],
              lj_post_id: post[:lj_post_id].to_i.zero? ? nil : post[:lj_post_id],
              lj_url_id: post[:lj_url_id].to_i.zero? ? nil : post[:lj_url_id],
              face_date: post[:post_date],
              updated_at: Time.zone.parse(post[:post_update])
          )
          column_names.map { |c| rec[c] }
        end
        table.fill(column_names, records)
        puts 'Done.'
      end

    end
  end
end
