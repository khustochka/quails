# frozen_string_literal: true

class PostDecorator < ModelDecorator
  def title
    OneLineFormatter.apply(@model.title_or_date)
  end

  def for_site
    @formatting_method = :for_site
    self
  end

  def for_feed
    @formatting_method = :for_feed
    self
  end

  def for_instant_articles
    @formatting_method = :for_instant_articles
    self
  end

  def for_lj
    @formatting_method = :for_lj
    self
  end

  def body
    WikiFormatter.new(@model.body, metadata).public_send(@formatting_method)
  end

  def metadata
    @metadata[:images] = the_rest_of_images unless @metadata.has_key?(:images)
    @metadata
  end

  def the_rest_of_images
    rel = @model.images
    if extract_image_slugs.present?
      rel = rel.where("slug NOT IN (?)", extract_image_slugs)
    end
    rel
  end

  private

  def extract_image_slugs
    @inner_image_slugs ||= @model.body.scan(/\{\{\^([^}]*)\}\}/).flatten
  end
end
