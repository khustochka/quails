# frozen_string_literal: true

FactoryBot.define do
  factory :spot do
    observation
    lat { 50.5 }
    lng { 30.6 }
    zoom { 12 }
    exactness { 0 }
    __send__(:public) { true }
  end
end
