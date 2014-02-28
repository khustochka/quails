require 'csv'
require 'ebird/converter_factory'

class EbirdExporter

  def initialize(filename, cards_rel)
    @filename = filename
    @cards = cards_rel.to_a
  end

  def export
    if @filename.present? && @cards.any?

      converter = EbirdConverterFactory.new(@cards)

      @result = observations.map do |obs|
        converter.new(obs).to_a
      end

      save_to_file(@result) unless Rails.env.test?

      true
    else
      false
    end
  end

  private

  def observations
    @cards.map {|c| c.observations.to_a }.flatten
  end

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
    path = ENV['quails_ebird_csv_path'] || "#{Rails.root}/public/csv"
    FileUtils.mkdir_p(path)
    path
  end

end
