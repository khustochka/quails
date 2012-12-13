# Customize RedCloth: no_span_caps by default, and use Russian double quotes
module RedCloth::Formatters::HTML

  def caps(opts)
    opts[:text]
  end

  # TODO: Select quotation marks based on locale
  def quote2(opts)
    "&#171;#{opts[:text]}&#187;"
  end

end
