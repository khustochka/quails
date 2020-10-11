# frozen_string_literal: true

FactoryBot.define do
  factory :spot do
    association :observation
    lat { 50.5 }
    lng { 30.6 }
    zoom { 12 }
    exactness { 0 }
    send(:public) { true }
  end
end
