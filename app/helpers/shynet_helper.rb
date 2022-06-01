# frozen_string_literal: true

module ShynetHelper
  def include_shynet
    # for some reason 'cache' inside helpers works only with concat
    # This may be related to calling = include_google_analytics vs - include_google_analytics
    if show_shynet?
      cache [:shynet, shynet_host, shynet_key] do
        concat(
          if show_shynet?
            render partial: "partials/shynet_code", locals: {host: shynet_host, key: shynet_key}
          end
        )
      end
    end
  end

  def show_shynet?
    shynet_analytics? && shynet_host.present? && shynet_key.present? && !may_be_admin?
  end

  private
  def shynet_host
    @@shynet_host ||= ENV["quails_shynet_host"]
  end

  def shynet_key
    @@shynet_key ||= ENV["quails_shynet_key"]
  end

  def user_key
    current_user.admin? ? "admin" : "visitor"
  end

  def shynet_analytics?
    Rails.configuration.analytics == "shynet"
  end
end
