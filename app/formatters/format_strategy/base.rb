# frozen_string_literal: true

module FormatStrategy
  class Base
    include Rails.application.routes.url_helpers

    WIKI_PREFIXES = -"@|#|\\^|&"
    WIKI_TAGS_REGEX = /\{\{(#{WIKI_PREFIXES}|)(?:([^\}]*?)\|)?([^\}]*?)(\|en)?\}\}/
    SPECIES_CODES_REGEX = /\{\{(?!#{WIKI_PREFIXES})(?:([^\}]*?)\|)?(.+?)(\|en)?\}\}/

    def initialize(text, metadata = {})
      @metadata = metadata
      @text = preprocess(text)
    end

    def apply
      prepare

      result = @text.gsub(WIKI_TAGS_REGEX) do |_|
        tag, word, term, en = $1, $2.try(:html_safe), $3, $4 # rubocop:disable Style/ParallelAssignment, Style/PerlBackrefs
        case tag
        when "@" then
          if term == "lj"
            lj_user(word)
          end
        when "#" then
          post_tag(word, term)
        when "^" then
          img_tag(term)
        when "&" then
          "notextile. " + video_embed(term)
        when "" then
          if term == "en"
            term = word
            word = nil
            en = "en"
          end
          species_tag(word, term, en)
        end
      end

      result.gsub!(/([Ввр])О([рн])/, '\1о&#769;\2')

      result << post_scriptum

      result
    end

    private

    def prepare
      wiki_tags = @text.scan(WIKI_TAGS_REGEX)

      post_terms = wiki_tags.filter_map do |tag, _word, term, _en|
        term if tag == "#"
      end.uniq

      preferred_langs = Post::COMPATIBLE_LANGUAGES[locale.to_sym] || [locale.to_s]
      @posts = if post_terms.any?
        cores_by_slug = PostCore.preload(:posts).where(slug: post_terms.map(&:downcase)).index_by(&:slug)
        post_terms.to_h do |term|
          core = cores_by_slug[term.downcase]
          pick = if core
            siblings = core.posts.index_by(&:lang)
            preferred_langs.lazy.filter_map { |lang| siblings[lang.to_s] }.first
          end
          [term, pick]
        end
      else
        {}
      end

      image_slugs = wiki_tags.filter_map do |tag, _word, term, _en|
        term if tag == "^"
      end.uniq
      @images = image_slugs.any? ? Image.preload(:species).where(slug: image_slugs).index_by(&:slug) : {}

      sp_codes = @text.scan(SPECIES_CODES_REGEX).map do |word, term|
        if term && term != "en"
          term
        else
          word
        end.sub("_", " ")
      end.uniq.compact

      # TODO: use already calculated species of the post! the rest will be ok with separate requests?
      if sp_codes.any?
        @spcs1 = Species.where("code IN (?) OR legacy_code IN (?) OR species.name_sci IN (?)", sp_codes, sp_codes, sp_codes)
        @spcs_syn = Species.select("species.*, url_synonyms.species_id, url_synonyms.name_sci AS synonym_name_sci")
          .joins(:url_synonyms).where("url_synonyms.name_sci" => sp_codes)
        @spcs = @spcs1 + @spcs_syn
        @species = {}
          .merge!(@spcs.index_by(&:code_or_slug))
          .merge!(@spcs.index_by(&:legacy_code))
          .merge!(@spcs1.index_by(&:name_sci))
          .merge!(@spcs_syn.index_by(&:synonym_name_sci))
      else
        @spcs = []
        @species = {}
      end
    end

    def preprocess(text)
      # Having \r breaks matching /^..$/
      text.gsub("\r\n", "\n")
    end

    def locale
      @metadata[:locale] || I18n.locale
    end
  end
end
