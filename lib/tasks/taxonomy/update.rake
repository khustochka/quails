# frozen_string_literal: true

# Year-agnostic taxonomy update. See Quails::TaxonomyUpdate.
namespace :taxonomy do
  find_csv = lambda do |year|
    ENV["CSV"] || Rails.root.glob("data/*.csv").find { |f| f.basename.to_s.downcase.start_with?("ebird_taxonomy_v#{year}") } ||
      abort("No eBird CSV for #{year} in data/; pass CSV=path.")
  end

  desc "Apply the eBird CSV and lib/tasks/taxonomy/YEAR/changes.yml. DRY_RUN=1 rolls back."
  task :update, [:year] => :environment do |_, args|
    year = args[:year].presence || abort("Usage: bin/rails taxonomy:update[2026]")
    manifest = Rails.root.join("lib/tasks/taxonomy/#{year}/changes.yml")
    abort "#{manifest} not found; run taxonomy:diff[#{year}] first." unless manifest.exist?

    Quails::TaxonomyUpdate::Applier.new(
      source: Quails::TaxonomyUpdate::Source.read(find_csv.call(year)),
      manifest: Quails::TaxonomyUpdate::Manifest.load(manifest),
      version: year,
      overrides: YAML.safe_load_file(Rails.root.join("lib/tasks/taxonomy/overrides.yml")),
      dry_run: ENV["DRY_RUN"].present?
    ).run
  rescue Quails::TaxonomyUpdate::Applier::Error => e
    abort e.message
  end

  desc "Check taxa, species and observations; with YEAR also list texts linking to that year's splits."
  task :verify, [:year] => :environment do |_, args|
    path = Rails.root.join("lib/tasks/taxonomy/#{args[:year]}/changes.yml")
    manifest = Quails::TaxonomyUpdate::Manifest.load(path) if args[:year].present? && path.exist?
    verifier = Quails::TaxonomyUpdate::Verifier.new(manifest: manifest)

    errors = verifier.errors
    { "Errors" => errors, "Warnings" => verifier.warnings, "Review" => verifier.review }.each do |title, items|
      puts "== #{title}", *items.map { |item| "  #{item}" }, ""
    end
    abort "#{errors.size} errors." if errors.any?
  end

  desc "Draft lib/tasks/taxonomy/YEAR/changes.yml from data/eBird_Taxonomy_vYEAR*.csv (or CSV=path). FORCE=1 overwrites."
  task :diff, [:year] => :environment do |_, args|
    year = args[:year].presence || abort("Usage: bin/rails taxonomy:diff[2026]")
    csv = find_csv.call(year)

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
