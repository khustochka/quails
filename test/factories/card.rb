# frozen_string_literal: true

FactoryBot.define do
  factory :card do
    transient do
      post { nil }
    end

    locus_id { Locus.find_by!(slug: "brovary").id }
    observ_date { "2010-06-18" }
    resolved { true }

    post_core { post&.post_core }
  end
end
