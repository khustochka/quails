# frozen_string_literal: true

require "csv"
require "export/strategies"

class Exporter
  def initialize(strategy, filename, cards, storage)
    @strategy = strategy
    @filename = filename
    @cards = cards
    @storage = storage
  end

  def self.ebird(filename:, cards:, storage:)
    new(EBirdStrategy.new(cards), filename, cards, storage)
  end

  # def self.rubirds(filename:, cards:, storage:)
  #   new(RubirdsStrategy.new(cards), filename, cards, storage)
  # end

  def export
    if @filename.present? && @cards.present?
      unless Rails.env.test?
        @storage.upload("#{@filename}.csv", StringIO.new(to_csv), content_type: "text/csv")
      end
      true
    else
      false
    end
  end

  def to_csv
    @result = @strategy.observations.map do |obs|
      @strategy.wrap(obs).to_a
    end
    CSV.generate do |csv|
      @result.each do |row|
        csv << row
      end
    end
  end
end
