module WikiFilter

  def transform(text)
    posts = Hash.new do |hash, term|
      hash[term] = Post.find_by_slug(term.downcase)
    end

    sp_codes = text.scan(/\[(?!#|@)(?:([^\]]*?)\|)?(.*?)\]/).map do |word, term|
      term || word
    end.uniq.compact

    # TODO: use already calculated species of the post! the rest will be ok with separate requests?
    spcs = Species.where("code IN (?) OR name_sci IN (?)", sp_codes, sp_codes)

    species = Hash.new do |hash, term|
      hash[term] = term.size == 6 ?
          spcs.find { |s| s.code == term } :
          spcs.find { |s| s.name_sci == term.sp_humanize }
    end

    result = text.gsub(/\[(@|#|)(?:([^\]]*?)\|)?(.*?)\]/) do |_|
      tag, word, term = $1, $2.try(:html_safe), $3
      case tag
        when '@' then
          link_to(word || term, term)
        when '#' then
          post = posts[term]
          post.nil? ?
              word :
              "\"#{word || post_title(post)}\":#{term}"
        when '' then
          sp = species[term]
          if sp
            species_link(sp, word || sp.name_sci)
          else
            term.size > 6 ? unknown_species(word, term) : (word || term)
          end
      end
    end

    if posts.any?
      result << "\n"

      posts.each do |slug, post|
        result << "\n[#{slug}]#{public_post_path(post)}" if post
      end
    end

    result

  end

end
