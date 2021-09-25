# frozen_string_literal: true

require "csv"
require "export/strategies"

class Exporter
  def initialize(strategy, filename, cards)
    @strategy = strategy
    @filename = filename
    @cards = cards
  end

  def self.ebird(filename, cards)
    new(EbirdStrategy.new(cards), filename, cards)
  end

  def self.rubirds(filename, cards)
    new(RubirdsStrategy.new(cards), filename, cards)
  end

  def export
    if @filename.present? && @cards.present?

      @result = @strategy.observations.map do |obs|
        @strategy.wrap(obs).to_a
      end

      save_to_file(@result) unless Rails.env.test?

      true
    else
      false
    end
  end

  private

  def save_to_file(array)
    CSV.open(local_file_name, "w+") do |csv|
      array.each do |row|
        csv << row
      end
    end
  end

  def local_file_name
    File.join(local_path, "#{@filename}.csv")
  end

  def local_path
    path = ENV["quails_ebird_csv_path"] || "tmp/csv"
    FileUtils.mkdir_p(path)
    path
  end
end
