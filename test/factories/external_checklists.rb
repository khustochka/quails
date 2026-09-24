# frozen_string_literal: true

FactoryBot.define do
  factory :external_checklist do
    sequence(:external_id) { |n| "S#{100_000_000 + n}" }
    time { "23 Sep 2026 7:15 AM" }
    location { "Brovary" }
    county { "Brovarskyi" }
    state_prov { "Kyiv, Ukraine" }
  end
end
