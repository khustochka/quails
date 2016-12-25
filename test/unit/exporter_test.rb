require 'test_helper'

require "export/exporter"

class ExporterTest < ActionView::TestCase

  test "card is successfuly exported if contains Unreported bird sp" do
    card = FactoryGirl.create(:card)
    obs1 = FactoryGirl.create(:observation, taxon: taxa(:pasdom), card: card)
    obs2 = FactoryGirl.create(:observation, taxon: taxa(:unreported_bird_sp), card: card)
    # Should not raise
    result = Exporter.ebird("Ebird_file", Card.where(id: card.id)).export
    assert result
  end

end
