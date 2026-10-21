# frozen_string_literal: true

module LogbookHelper
  # Describes the list a Logbook::Entry was added to, e.g. "New for Manitoba 2025 (123)",
  # followed by the covered life lists. List totals link to the species' anchors in the
  # corresponding lifelists.
  def logbook_entry_label(entry)
    label = safe_join([logbook_list_title(entry), " ", logbook_total_link(entry.list_total, entry.locus, entry.year)])
    covered = entry.covered.map do |locus, total|
      safe_join([", new species in #{locus.name_en} ", logbook_total_link(total, locus)])
    end
    safe_join([label, *covered])
  end

  # Species of a Logbook::Entry; World lifers are emphasized.
  def logbook_species(entry)
    lifer = entry.type == :life && entry.locus.nil?
    links = entry.observations.map do |obs|
      link = species_link(obs.species)
      lifer ? tag.strong(link) : link
    end
    safe_join(links, ", ")
  end

  private

  def logbook_list_title(entry)
    count = entry.observations.size
    area = entry.locus&.name_en
    if count == 1
      case [entry.type, area.nil?]
      in [:life, true] then "New lifer"
      in [:life, false] then "New species in #{area}"
      in [:year, true] then "New species for #{entry.year}"
      in [:year, false] then "New for #{area} #{entry.year}"
      end
    else
      case [entry.type, area.nil?]
      in [:life, true] then "Added #{count} new lifers"
      in [:life, false] then "Added #{count} new species in #{area}"
      in [:year, true] then "Added #{count} new species for #{entry.year}"
      in [:year, false] then "Added #{count} new species for #{area} #{entry.year}"
      end
    end
  end

  def logbook_total_link(total, locus, year = nil)
    tag.span(class: "logbook-total") do
      safe_join(["(", link_to(total, list_path(locus: locus&.slug, year: year, anchor: "lifer-#{total}"), class: "not-green"), ")"])
    end
  end
end
