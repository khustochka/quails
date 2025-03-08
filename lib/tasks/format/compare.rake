# frozen_string_literal: true

desc "Formatter tasks"
namespace :format do
  desc "Compare old and new formatters"
  task compare: :environment do
    Post.where.not(title: nil)
      .and(Post.where.not(title: ""))
      .find_each do |obj|
      I18n.with_locale(obj.lang.to_sym) do
        oldf =
          Converter::Textile.one_line(obj.title)
            # Converter::Textile.paragraph(card.notes)
            #   .strip
            #   .gsub("</p>\n<p>", "</p>\n\n<p>")
            .gsub("&#8217;", "’")
            .gsub("&#8211;", "-")
            .gsub("&#8212;", "-")
            .gsub("&#8230;", "…")
        newf =
          Converter::Kramdown.one_line(obj.title)
        # Converter::Kramdown.paragraph(card.notes).strip
        if newf != oldf
          puts "Post ##{obj.slug}"
          puts "================"
          puts "Old"
          puts oldf
          puts "================"
          puts "New"
          puts newf
          puts "================\n\n\n"
        end
      end
    end
  end
end
