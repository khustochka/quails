ALL_LOCALES = [:en, :ru, :uk]
DEFAULT_PUBLIC_LOCALE = :ru

I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
