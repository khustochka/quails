class InstantArticlesFormatStrategy < FeedFormatStrategy

  private

  def preprocess(text)
    new_text = super(text)
    # Replace h3 with h2, h4-6 with strong
    new_text.
        gsub(/^h3\./i, "h2.").
        gsub(/<(\/?)h3/i, '<\1h2').
        gsub(/^h[4-6]\.\s+(.*)$/i, '*\1*').
        gsub(/<(\/?)h[4-6]/i, '<\1strong')
  end

end
