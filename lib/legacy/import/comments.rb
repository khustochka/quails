require 'legacy/mapping'

module Legacy
  module Import
    class Comments

      def self.import_comments(comments)

        Legacy::Mapping.refresh_posts

        puts 'Importing comments...'

        table = BunchDB::Table.new('comments')
        column_names = Comment.column_names
        records = comments.map do |c|
          rec = HashWithIndifferentAccess.new(
              :id => c[:cid],
              :post_id => Legacy::Mapping.posts[c[:ref]],
              :parent_id => c[:talk],
              :text => c[:ctext],
              :name => c[:name],
              :url => c[:url],
              :created_at => c[:cdate],
              :approved => c[:approved]
          )
          column_names.map { |cn| rec[cn] }
        end
        table.fill(column_names, records)
        table.reset_pk_sequence!
        puts "Done."
      end
    end
  end
end
