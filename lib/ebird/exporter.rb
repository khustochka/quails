require 'csv'
require 'ebird/observation'

class EbirdExporter

  def initialize(filename, cards_rel)
    @filename = filename
    @cards = cards_rel
  end

  def export
    if @filename.present? && @cards.present?

      @result = observations.map do |obs|
        EbirdObservation.new(obs).to_a
      end

      save_to_file(@result) unless Rails.env.test?

      true
    else
      false
    end
  end

  private

  def observations
    Observation.where(card_id: @cards).preload(:images, :species, :card => :locus)
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
