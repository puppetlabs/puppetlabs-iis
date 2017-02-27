require 'spec_helper_acceptance'

# Disabled on 2008 due to bug in Get-Website behaviour (MODULES-4463)
describe 'a minimal IIS config:', :if => fact('kernelmajversion') != '6.1' do
  before(:all) do
    @manifest = <<-EOF
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
    @result = apply_manifest(@manifest, acceptable_exit_codes: (0...256))
  end

  it_behaves_like 'an idempotent resource'
end
