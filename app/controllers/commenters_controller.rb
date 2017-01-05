class CommentersController < ApplicationController

  administrative only: [:index]

  PROVIDER_URL_KEY = {
      facebook: "Facebook",
      flickr: "Photos"
  }.with_indifferent_access

  def login
    Rails.logger.warn(auth_hash.to_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]
    @commenter = Commenter.find_or_create_by(provider: provider, uid: uid)
    if @commenter
      @commenter.update_attributes(
          name: auth_hash[:info][:name],
          url: auth_hash[:info][:urls][PROVIDER_URL_KEY[provider]],
          image: auth_hash[:info][:image],
          auth_hash: auth_hash.to_h.with_indifferent_access
      )
      session[:commenter_id] = @commenter.id
      render partial: "commenters/form/#{provider}", locals: {commenter: @commenter}, layout: false
    else
      render status: 404
    end
  end

  def index
    @commenters = Commenter.order(:id)
  end

  protected

  def auth_hash
    @auth_hash ||= request.env['omniauth.auth']
  end

end
