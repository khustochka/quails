# frozen_string_literal: true

require "seeds/table"

module Seeds

  SEED_TABLES = %w(ebird_taxa taxa species species_splits url_synonyms ioc_taxa local_species
                   loci)

  SEED_DIR = File.join(ENV["HOME"], "bwseed")
  SEED_REPO = -"https://gist.github.com/2697b86d7f7d1ca8e93a74c593237068.git"

  def self.load_all
    seed_init_if_necessary!

    dirname = SEED_DIR
    ActiveRecord::Base.connection.disable_referential_integrity do
      SEED_TABLES.each do |table_name|
        filename = "#{dirname}/#{table_name}.yml"

        raw = YAML.load(File.new(filename), "r")

        data = raw[table_name]

        table = Seeds::Table.new(table_name)
        table.cleanup

        column_names = data["columns"]
        records = data["records"]

        table.fill(column_names, records)

        table.reset_pk_sequence!
      end
    end
  end

  def self.dump_all
    seed_init_if_necessary!

    dirname = SEED_DIR

    SEED_TABLES.each do |table_name|
      puts "Dumping '#{table_name}'..."
      io = File.new File.join(dirname, "#{table_name}.yml"), "w"
      table = Seeds::Table.new(table_name)
      table.dump(io)
      io.close
    end

    commit_or_diff!
  end

  private

  def self.seed_init_if_necessary!
    unless seed_inited?
      system("git clone #{SEED_REPO} #{SEED_DIR}")
    end
  end

  def self.seed_inited?
    File.exist?(SEED_DIR)
  end

  def self.commit_or_diff!
    msg = "Seed update #{Time.now}"

    Dir.chdir(SEED_DIR) do
      if ENV["DEBUG"].nil? || ENV["DEBUG"] == "false"
        system("git add *.yml")
        system("git commit -m '#{msg}'")
        system("git push origin master")
      else
        system "git diff"
      end
    end
  end

end
