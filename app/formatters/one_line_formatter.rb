# frozen_string_literal: true

module OneLineFormatter
  def self.apply(str)
    # rubocop:disable Rails/OutputSafety
    RedCloth.new(str, [:lite_mode]).to_html.html_safe
  end
end
