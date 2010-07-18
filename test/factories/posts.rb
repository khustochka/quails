# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :post do |f|
  f.code "MyString"
  f.title "MyString"
  f.text "MyText"
  f.topic "MyString"
  f.status "MyString"
  f.lj_post_id 1
  f.lj_url_id 1
end
