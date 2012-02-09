ALL_LOCALES = [:en, :ru, :uk]
DEFAULT_PUBLIC_LOCALE = :en # will be changed to :ru

I18n::Backend::Simple.send(:include, I18n::Backend::Pluralization)
