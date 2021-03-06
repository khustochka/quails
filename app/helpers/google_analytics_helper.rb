module GoogleAnalyticsHelper
  def include_google_analytics
    # for some reason 'cache' inside helpers works only with concat
      cache [:ga, show_ga: show_ga?] do
        concat(
          if show_ga?
            render partial: "partials/ga_code", object: ga_code, as: :code
          end
        )
      end
  end

  def show_ga?
    ga_code.present? && !may_be_admin?
  end

  private

  def ga_code
    @@ga_code ||= ENV["quails_ga_code"]
  end
end