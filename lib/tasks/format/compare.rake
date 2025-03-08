# frozen_string_literal: true

desc "Formatter tasks"
namespace :format do
  desc "Compare old and new formatters"
  task compare: :environment do
    Card.where.not(notes: nil)
      .and(Card.where.not(notes: ""))
      .find_each do |card|
      oldf =
        Converter::Textile.paragraph(card.notes)
          .strip
          .gsub("</p>\n<p>", "</p>\n\n<p>")
          .gsub("&#8217;", "’")
          .gsub("&#8211;", "-")
          .gsub("&#8212;", "-")
      newf = Converter::Kramdown.paragraph(card.notes).strip
      if newf != oldf
        puts "Card ##{card.id}"
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
