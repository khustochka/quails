# Deprecation message fix for Capybara webkit.
# The project was discontinued and the fix was not released.

module Capybara::Webkit
  class Node < Capybara::Driver::Node

    def visible_text
      text = invoke(:text).to_s
      if Capybara::VERSION.to_f < 3.0
        Capybara::Helpers.normalize_whitespace(text)
      else
        text.gsub(/\ +/, ' ')
            .gsub(/[\ \n]*\n[\ \n]*/, "\n")
            .gsub(/\A[[:space:]&&[^\u00a0]]+/, "")
            .gsub(/[[:space:]&&[^\u00a0]]+\z/, "")
            .tr("\u00a0", ' ')
      end
    end
    alias_method :text, :visible_text

    def all_text
      text = invoke(:allText)
      if Capybara::VERSION.to_f < 3.0
        Capybara::Helpers.normalize_whitespace(text)
      else
        text.gsub(/[\u200b\u200e\u200f]/, '')
            .gsub(/[\ \n\f\t\v\u2028\u2029]+/, ' ')
            .gsub(/\A[[:space:]&&[^\u00a0]]+/, "")
            .gsub(/[[:space:]&&[^\u00a0]]+\z/, "")
            .tr("\u00a0", ' ')
      end
    end

  end
end
