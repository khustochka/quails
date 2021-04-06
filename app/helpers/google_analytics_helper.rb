# frozen_string_literal: true

module GoogleAnalyticsHelper
  def include_google_analytics
    # for some reason 'cache' inside helpers works only with concat
    # This may be related to calling = include_google_analytics vs - include_google_analytics
    if show_ga?
      cache [:ga, ga_code] do
        concat(
          if show_ga?
            render partial: "partials/ga_code", object: ga_code, as: :code
          end
        )
      end
    end
  end

  def show_ga?
    ga_analytics? && ga_code.present? && !may_be_admin?
  end

  private

  def ga_code
    @@ga_code ||= ENV["quails_ga_code"]
  end

  def ga_analytics?
    Rails.configuration.analytics == "ga"
  end
end
