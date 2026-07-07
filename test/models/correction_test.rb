# frozen_string_literal: true

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

  test "validity of the resulting query is checked" do
    correction = build(:correction, sort_column: "nonexistent_column")
    assert_not_predicate correction, :valid?
    # This checks that there is no exception raised
    assert_not correction.save
  end

  test "#query_valid? is true for a working query" do
    correction = create(:correction)
    assert_predicate correction, :query_valid?
  end

  test "#query_valid? is true for a valid query matching no records" do
    correction = create(:correction)
    assert_predicate correction, :query_valid?
  end

  test "#query_valid? is false when the query became invalid after creation" do
    correction = create(:correction)
    # Simulate a query that broke later (e.g. a column was removed),
    # bypassing validation by writing the column directly.
    correction.update_column(:query, "posts.nonexistent_column = 1")
    assert_not_predicate correction, :query_valid?
  end

  test "#results returns an empty relation for an invalid query" do
    correction = create(:correction)
    correction.update_column(:query, "posts.nonexistent_column = 1")
    assert_empty correction.results
  end

  test "#count returns 0 for an invalid query" do
    correction = create(:correction)
    correction.update_column(:query, "posts.nonexistent_column = 1")
    assert_equal 0, correction.count
  end

  test "#count returns the number of matching records" do
    correction = create(:correction)
    create(:post, body: "Link http://google.com")
    create(:post, body: "Link https://google.com")
    assert_equal 1, correction.count
  end
end
