module CardsHelper

  def attach_detach_link(card)

    if @post.id == card.post_id
      text = 'Detach from this post'
      post_id = nil
    else
      text = 'Attach to this post'
      post_id = @post.id
    end

    link_to text, card_path(card, format: :json), class: 'card_post_op pseudolink', remote: true,
            method: :put, data: {confirm: 'Are you sure?', params: "card[post_id]=#{post_id}"}
  end

  # NOTICE: should always be called @observation_search !                                                                                         Observation
  def show_separate_observation_on_card_search?
    @observation_search.try(:observations_filtered?)
  end

end
