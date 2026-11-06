# frozen_string_literal: true

# Year-agnostic taxonomy update. See Quails::TaxonomyUpdate.
namespace :tax do
  desc "Draft lib/tasks/taxonomy/YEAR/changes.yml from data/eBird_Taxonomy_vYEAR*.csv (or CSV=path). FORCE=1 overwrites."
  task :diff, [:year] => :environment do |_, args|
    year = args[:year].presence || abort("Usage: bin/rails tax:diff[2026]")
    csv = ENV["CSV"] || Rails.root.glob("data/*.csv").find { |f| f.basename.to_s.downcase.start_with?("ebird_taxonomy_v#{year}") }
    abort "No eBird CSV for #{year} in data/; pass CSV=path." unless csv

    out = Rails.root.join("lib/tasks/taxonomy/#{year}/changes.yml")
    abort "#{out} exists and may hold your review; set FORCE=1 to overwrite." if out.exist? && ENV["FORCE"].blank?

    puts "Reading #{csv}"
    differ = Quails::TaxonomyUpdate::Differ.new(Quails::TaxonomyUpdate::Source.read(csv))
    manifest = differ.to_h

    FileUtils.mkdir_p(out.dirname)
    header = "# Draft taxonomy changes for #{year}, generated from #{File.basename(csv)}.\n" \
      "# Review each entry and set status to ok or skip.\n"
    File.write(out, header + manifest.to_yaml(line_width: -1))

    puts "Wrote #{out}"
    manifest["entries"].group_by { |e| e["type"] }.each { |type, list| puts "  #{type}: #{list.size}" }
    puts "  removed_unused: #{manifest["removed_unused"].size}"
  end
end
