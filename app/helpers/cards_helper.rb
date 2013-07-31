module CardsHelper

  KML_LOGO = "http://images2.wikia.nocookie.net/__cb20101130020153/logopedia/images/thumb/9/9e/Google_Earth_logo.png/80px-Google_Earth_logo.png"

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
            method: :put, data: {confirm: 'Are you sure?', params: "#{item.class.to_s.downcase}[post_id]=#{post_id}"}
  end

  # NOTICE: should always be called @observation_search !                                                                                         Observation
  def show_separate_observation_on_card_search?
    @observation_search.try(:observations_filtered?)
  end

  def suggested_dates
    prelim = {
        Date.today => ['Today'],
        Date.yesterday => ['Yesterday']
    }
    last_date = Card.pluck('MAX(observ_date)').first
    if last_date
      prelim[last_date + 1] = ['Last unreported']
    end
    if @card.persisted?
      prelim[@card.observ_date] = ["Same day as this card"]
      prelim[@card.observ_date + 1] = ["Next day to this card"]
    end
    prelim
  end

end
