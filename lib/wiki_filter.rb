module WikiFilter

  def transform(text)
    posts = Hash.new do |hash, term|
      hash[term] = Post.find_by_code(term.downcase)
    end

    sp_codes = text.gsub(/\[(?!#|@)(?:([^\]]*?)\|)?(.*?)\]/).map do |full|
      $2 || $1
    end.uniq.compact

    # TODO: IDEA: use already calculated species of the post! the rest will be ok with separate requests?
    spcs = Species.where("code IN (?) OR name_sci IN (?)", sp_codes, sp_codes)

    species = Hash.new do |hash, term|
      hash[term] = term.size == 6 ?
          spcs.find { |s| s.code == term } :
          spcs.find { |s| s.name_sci == term.sp_humanize }
    end

    text.gsub(/\[(@|#|)(?:([^\]]*?)\|)?(.*?)\]/) do |full|
      tag, word, code = $1, $2.try(:html_safe), $3
      case tag
        when '@' then
          link_to(word || code, code)
        when '#' then
          post = posts[code]
          post.nil? ?
              word :
              post_link(word || post_title(post), post, true)
        when '' then
          sp = species[code]
          if sp
            species_link(sp, word || sp.name_sci)
          else
            code.size > 6 ? unknown_species(word, code) : (word || code)
          end
      end
    end
  end

end
