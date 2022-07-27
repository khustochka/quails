# frozen_string_literal: true

require "test_helper"

require "export/exporter"

class ExporterTest < ActiveSupport::TestCase
  test "card is successfuly exported if contains Unreported bird sp" do
    card = FactoryBot.create(:card)
    obs1 = FactoryBot.create(:observation, taxon: taxa(:pasdom), card: card)
    obs2 = FactoryBot.create(:observation, taxon: taxa(:unreported_bird_sp), card: card)
    # Should not raise
    result = Exporter.ebird(filename: "EBird_file", cards: Card.where(id: card.id), storage: nil).to_csv
    assert result
  end
end
