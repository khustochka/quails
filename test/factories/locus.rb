# frozen_string_literal: true

FactoryBot.define do
  factory :locus do
    sequence(:slug) {|n| "locus_#{(n % 26 + 65).chr}" }
    parent_id { nil }
    sequence(:name_en) {|n| "Locus name #{(n % 26 + 65).chr}" }
    sequence(:name_ru) {|n| "Locus ru #{(n % 26 + 65).chr}" }
    sequence(:name_uk) {|n| "Назва #{(n % 26 + 65).chr}" }
    lat { 0 }
    lon { 0 }
  end
end
