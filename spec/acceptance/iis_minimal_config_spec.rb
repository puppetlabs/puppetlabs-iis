# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'a minimal IIS config:', :suite_a do
  manifest = <<-EOF
    file {'c:\\inetpub\\minimal':
      ensure => directory,
      source => 'C:\\inetpub\\wwwroot',
      recurse => true
    }
    iis_site { 'minimal':
      ensure          => 'stopped',
      physicalpath    => 'c:\\inetpub\\minimal',
      applicationpool => 'DefaultAppPool',
    }
  EOF

  iis_idempotent_apply('create app', manifest)
end
