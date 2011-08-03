module WikiFilter

  def transform(text)
    posts = Hash.new do |hash, term|
      hash[term] = Post.find_by_code(term.downcase)
    end
    species = Hash.new do |hash, term|
      hash[term] = term.size == 6 ?
          Species.find_by_code(term.downcase) :
          Species.find_by_name_sci(latin_url_humanize(term))
    end

    text.gsub(/\[(@|#|)(?:(.*?)\|)?(.*?[^\\])\]/) do |full|
      tag, word, code = $1, $2, $3
      return full if $` =~ /(^|[^\\])\\$/
      case tag
        when '@' then
          link_to(word || code, code)
        when '#' then
          post = posts[code]
          post.nil? ?
              word :
              post_link(word || post.title, post, true)
        when '' then
          sp = species[code]
          sp.nil? ?
              word :
              species_link(sp, word || (code.size == 6 ? nil : sp.name_sci))
      end
    end.gsub /\\([\\\[\]])/, '\1' # Screened [, ] and \
  end

end