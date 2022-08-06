require "test_helper"

class CorrectionTest < ActiveSupport::TestCase
  test "#results makes the correct query" do
    correction = create(:correction)
    post1 = create(:post, body: "Link http://google.com", face_date: "2022-08-02")
    post2 = create(:post, body: "Link https://google.com", face_date: "2022-08-01")
    post3 = create(:post, body: "Link http://flickr.com", face_date: "2022-07-29")
    assert_equal [post3, post1], correction.results.to_a
  end

  test "#next_after returns the next record" do
    correction = create(:correction)
    post1 = create(:post, body: "Link http://google.com", face_date: "2022-08-02")
    post2 = create(:post, body: "Link https://google.com", face_date: "2022-08-01")
    post3 = create(:post, body: "Link http://flickr.com", face_date: "2022-07-29")
    assert_equal post1, correction.next_after(post3)
  end
end
