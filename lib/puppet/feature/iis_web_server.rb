require 'puppet/util/feature'
require_relative '../../../lib/puppet_x/puppetlabs/iis/iis_version'

Puppet.features.add(:iis_web_server) do
  PuppetX::PuppetLabs::IIS::IISVersion.supported_version_installed?
end

Puppet.features.send :meta_def, 'iis_web_server?' do
  name = :iis_web_server
  @results[name] = PuppetX::PuppetLabs::IIS::IISVersion.supported_version_installed? unless @results[name]
  @results[name]
end
