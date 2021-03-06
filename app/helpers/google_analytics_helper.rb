module GoogleAnalyticsHelper
  def include_google_analytics
    # for some reason 'cache' does not work inside helpers
    if show_ga?
      render partial: "partials/ga_code", object: ga_code, as: :code
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