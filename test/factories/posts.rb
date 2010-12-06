# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :post do |f|
  f.code "test-post"
  f.title "Test Post"
  f.text <<TEXT
This is a post text.

It must be multiline.
TEXT
  f.topic "OBSR"
  f.status "OPEN"
#  f.lj_post_id 0
#  f.lj_url_id 0
end
