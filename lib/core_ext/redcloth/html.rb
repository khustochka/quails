# frozen_string_literal: true

# Customize RedCloth
module RedCloth::Formatters::HTML
  # Set no_span_caps by default
  def caps(opts)
    opts[:text]
  end

  alias_method :__quote2, :quote2
  # Select quotation marks based on locale (RUS, UKR)
  def quote2(opts)
    if defined?(I18n) && I18n.locale.in?([:ru, :uk])
      "«#{opts[:text]}»"
    else
      __quote2(opts)
    end
  end

  # def endash(opts)
  #   " – "
  # end
end
