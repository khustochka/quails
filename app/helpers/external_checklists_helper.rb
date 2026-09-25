# frozen_string_literal: true

module ExternalChecklistsHelper
  STATUS_ICONS = {
    "pending" => "fa-clock",
    "requested" => "fa-spinner fa-spin",
    "imported" => "fa-circle-check",
    "failed" => "fa-circle-exclamation",
  }.freeze

  def external_checklist_status_icon(status)
    tag.span(class: "fas #{STATUS_ICONS[status]}", "aria-hidden": "true")
  end
end
