# frozen_string_literal: true

module LogbookHelper
  # Describes the list a Logbook::Entry was added to, e.g. "New species for Manitoba 2025 (123)",
  # followed by the covered life lists. List totals link to the species' anchors in the
  # corresponding lifelists.
  def logbook_entry_label(entry)
    label = safe_join([logbook_list_title(entry), " ", logbook_total_link(entry.list_total, entry.locus, entry.year)])
    covered = entry.covered.map do |locus, total|
      safe_join([t("logbook.covered", area: locus.name), " ", logbook_total_link(total, locus)])
    end
    star = logbook_star if entry.type == :life && entry.locus.nil?
    safe_join([star, label, *covered].compact)
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

  def logbook_star
    tag.span(class: "fas fa-star logbook-star", "aria-hidden": "true")
  end

  def logbook_list_title(entry)
    count = entry.observations.size
    lifers = entry.type == :life && entry.locus.nil?
    what =
      if count == 1
        t(lifers ? "logbook.one_lifer" : "logbook.one_species")
      else
        t(lifers ? "logbook.added_lifers" : "logbook.added_species", count: count)
      end
    kind = "#{entry.type}_#{entry.locus ? "area" : "world"}"
    t("logbook.list.#{kind}", what: what, area: entry.locus&.name, year: entry.year)
  end

  def logbook_total_link(total, locus, year = nil)
    tag.span(class: "logbook-total") do
      safe_join(["(", link_to(total, list_path(locus: locus&.slug, year: year, anchor: "lifer-#{total}"), class: "not-green"), ")"])
    end
  end
end
