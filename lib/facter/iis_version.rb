Facter.add('iis_version') do
  confine kernel: :windows
  setcode do
    require_relative '../puppet_x/puppetlabs/iis/iis_version'
    PuppetX::PuppetLabs::IIS::IISVersion.installed_version
  end
end
