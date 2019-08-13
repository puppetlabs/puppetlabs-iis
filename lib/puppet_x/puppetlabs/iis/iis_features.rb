# The Puppet Extensions Module
module PuppetX
  # IIS
  module IIS
    # Features
    module Features
      def iis_feature?(feature_name)
        # Note this code uses an array of the latest IIS features available to
        # install, but does not keep track of which subset is available in a given
        # IIS distribution. We could have kept track but since there are only a
        # handful of added features from 7.5 to 8.5, it was thought it would be
        # easier to have one array to check rather than keep a seperate list per
        # IIS version. In short, we defer to the tooling to tell us what feature is
        # present in which IIS version and only keep track of the larger list.
        IIS_INSTALLABLE_FEATURES.include?(feature_name.downcase)
      end
      module_function :iis_feature?

      # Note - In order to make comparisions easier, all text should be lowercase.
      IIS_INSTALLABLE_FEATURES = [
        'web-app-dev',
        'web-appinit',
        'web-application-proxy',
        'web-asp',
        'web-asp-net',
        'web-asp-net45',
        'web-basic-auth',
        'web-cert-auth',
        'web-certprovider',
        'web-cgi',
        'web-client-auth',
        'web-common-http',
        'web-custom-logging',
        'web-dav-publishing',
        'web-default-doc',
        'web-digest-auth',
        'web-dir-browsing',
        'web-dyn-compression',
        'web-filtering',
        'web-ftp-ext',
        'web-ftp-server',
        'web-ftp-service',
        'web-health',
        'web-http-errors',
        'web-http-logging',
        'web-http-redirect',
        'web-http-tracing',
        'web-includes',
        'web-ip-security',
        'web-isapi-ext',
        'web-isapi-filter',
        'web-lgcy-mgmt-console',
        'web-lgcy-scripting',
        'web-log-libraries',
        'web-metabase',
        'web-mgmt-compat',
        'web-mgmt-console',
        'web-mgmt-service',
        'web-mgmt-tools',
        'web-net-ext',
        'web-net-ext45',
        'web-odbc-logging',
        'web-performance',
        'web-request-monitor',
        'web-scripting-tools',
        'web-security',
        'web-server',
        'web-stat-compression',
        'web-static-content',
        'web-url-auth',
        'web-webserver',
        'web-websockets',
        'web-whc',
        'web-windows-auth',
        'web-wmi',
      ].freeze
    end
  end
end
