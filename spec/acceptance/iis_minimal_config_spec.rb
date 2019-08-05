require 'spec_helper_acceptance'

describe 'a minimal IIS config:' do
  describe "apply manifest twice" do
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

    it_behaves_like 'an idempotent resource', manifest
  end
end
