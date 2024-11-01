# frozen_string_literal: true

desc "Replaces old species tags in posts with sci names"
task fix_posts_codes: :environment do
  Post.find_each do |post|
    tags = post.body.scan(/\{\{([^\^&#][^|{}]*)\|(\w{6})(?:\|(en))?\}\}/).reject(&:empty?)

    if tags.any?
      puts "\n\n========="
      puts post.slug
      puts "=========\n"

      body = post.body

      tags.each do |txt, code, en|
        old_tag = "{{#{[txt, code, en].compact.join("|")}}}"

        sp = Species.find_by(code: code) || Species.find_by(legacy_code: code)

        new_tag = "{{#{[txt, sp.name_sci, en].compact.join("|")}}}"

        puts "#{old_tag} -> #{new_tag}"

        body.gsub!(old_tag, new_tag)
      end

      post.update!(body: body)
    end
  end
end
