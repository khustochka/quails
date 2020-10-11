# frozen_string_literal: true

# Customize RedCloth: no_span_caps by default, and use Russian double quotes
module RedCloth::Formatters::HTML

  def caps(opts)
    opts[:text]
  end

  # TODO: Select quotation marks based on locale
  def quote2(opts)
    "«#{opts[:text]}»"
  end

  def endash(opts)
    " – "
  end

end
