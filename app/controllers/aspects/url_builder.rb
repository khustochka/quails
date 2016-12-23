module Aspects
  module UrlBuilder
    def self.included(klass)
      #klass.extend ClassMethods
      klass.helper_method :admin_pages_url_options, :admin_url_options, :public_url_options
    end

    protected

    # URL options for links to admin-only pages (that's why locale is forced to nil)
    def admin_pages_url_options
      @@admin_pages_url_options ||= {locale: nil}.merge!(admin_url_options)
    end

    def admin_url_options
      @@admin_url_options ||= pumadev_admin_url_options.merge(ssl_url_options)
    end

    def public_url_options
      @@public_url_options ||= pumadev_public_url_options.merge(anti_ssl_url_options)
    end

    private

    PUMA_DEV_SSL_PORT = 9283
    PUMA_DEV_HTTP_PORT = 9280

    def pumadev_admin_url_options
      @@pumadev_admin_url_options ||= if Quails.env.puma_dev?
                                        {port: PUMA_DEV_SSL_PORT}
                                      else
                                        {}
                                      end
    end

    def pumadev_public_url_options
      @@pumadev_public_url_options ||= if Quails.env.puma_dev?
                                         {port: PUMA_DEV_HTTP_PORT}
                                       else
                                         {}
                                       end
    end

    def ssl_url_options
      @@ssl_url_options ||= if Quails.env.ssl?
                              {only_path: false, protocol: 'https'}
                            else
                              {}
                            end
    end

    def anti_ssl_url_options
      @@anti_ssl_url_options ||= if Quails.env.ssl?
                                   {only_path: false, protocol: 'http'}
                                 else
                                   {}
                                 end
    end

  end
end
