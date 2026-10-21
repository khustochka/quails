# frozen_string_literal: true

module LogbookHelper
  # Describes the list a Logbook::Entry was added to, e.g. "New for Manitoba 2025 (123)",
  # followed by the covered life lists. List totals link to the corresponding lifelists.
  def logbook_entry_label(entry)
    label = safe_join([logbook_list_title(entry), " ", logbook_total_link(entry.list_total, entry.locus, entry.year)])
    label = tag.strong(label) if entry.type == :life && entry.locus.nil?
    covered = entry.covered.map do |locus, total|
      safe_join([", new species in #{locus.name_en} ", logbook_total_link(total, locus)])
    end
    safe_join([label, *covered])
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
      safe_join(["(", link_to(total, advanced_list_path(locus: locus&.slug, year: year, locale: nil)), ")"])
    end
  end
end
