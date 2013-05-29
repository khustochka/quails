module CardsHelper

  def attach_detach_link(item) # Card or observation

    if @post.id == item.post_id
      text = 'Detach from this post'
      post_id = nil
    else
      text = 'Attach to this post'
      post_id = @post.id
    end

    url = url_for(controller: item.class.to_s.tableize, action: :update, id: item.id, format: :json)

    link_to text, url, class: 'card_post_op pseudolink', remote: true,
            method: :put, data: {confirm: 'Are you sure?', params: "#{item.class.to_s.singularize.downcase}[post_id]=#{post_id}"}
  end

  # NOTICE: should always be called @observation_search !                                                                                         Observation
  def show_separate_observation_on_card_search?
    @observation_search.try(:observations_filtered?)
  end

end
