FactoryBot.define do
  factory :correction do
    model_classname { "Post" }
    query { "posts.body ILIKE '%http://%'" }
    sort_column { "face_date" }
  end
end
