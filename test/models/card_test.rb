require 'test_helper'

class CartTest < ActiveSupport::TestCase

  test 'card is unlinked from post when post is destroyed' do
    p = create(:post)
    card = create(:card, post_id: p.id)
    p.destroy
    assert_nil card.reload.post_id
  end

end
