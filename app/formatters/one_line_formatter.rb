# frozen_string_literal: true

module OneLineFormatter
  def self.apply(str)
    RedCloth.new(str, [:lite_mode]).to_html.html_safe # rubocop:disable Rails/OutputSafety
  end
end
