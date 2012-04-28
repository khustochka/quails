module StrictTranslationHelper
  unless Rails.env.production?
    include ActionView::Helpers::TranslationHelper

    def translate(key, options = {})
      super(key, options.reverse_merge(raise: true))
    end

    alias :t :translate
  end
end
