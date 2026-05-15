# frozen_string_literal: true

module CardsHelper
  # FAST_LOCI = %w(geologorozvidka kyiv brovary les_i_pole)
  FAST_LOCI = %w(harbourview_south winnipeg_regent terracon_pl dugald_rd winnipeg)

  # item: Card or observation. `post` is a Post (we attach to its core).
  def post_attach_detach_link(item, post)
    core_id = post.post_core_id
    if core_id == item.post_core_id
      text = "Detach from this post"
      target_core_id = nil
    else
      text = "Attach to this post"
      target_core_id = core_id
    end

    url = url_for(controller: item.class.model_name.route_key, action: :update, id: item.id, format: :json)

    link_to text, url, class: "card_post_op pseudolink", remote: true,
      method: :put, data: { confirm: "Are you sure?", params: "#{item.class.model_name.param_key}[post_core_id]=#{target_core_id}" }
  end

  def suggested_dates(card)
    prelim = {
      Time.zone.today => ["Today"],
      Time.zone.yesterday => ["Yesterday"],
    }
    last_date = Card.maximum(:observ_date)
    if last_date
      prelim[last_date + 1] = ["Last unreported"]
    end
    if card.persisted?
      prelim[card.observ_date] = ["Same day as this card"]
      prelim[card.observ_date + 1] = ["Next day to this card"]
    end
    prelim
  end

  def fast_loci
    @fast_loci ||= Locus.where(slug: FAST_LOCI).index_by(&:slug)
  end
end
