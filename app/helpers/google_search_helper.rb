module GoogleSearchHelper

  def include_google_search
    # for some reason 'cache' inside helpers works only with concat
    # This may be related to calling = include_google_analytics vs - include_google_analytics
    cache [:google_search_old, locale: I18n.locale] do
      concat(
        render partial: "partials/search"
      )
    end
  end

  def google_cse
    # FIXME: temporarily disable CSE: in does not work in IE7/8 (JS) and standard Google search actually looks better.
    nil
    #@@google_cse ||= ENV["quails_google_cse"]
  end

  def google_search_form_url
    if google_cse
      "//www.google.com/cse"
    else
      "//www.google.com/search"
    end
  end
end