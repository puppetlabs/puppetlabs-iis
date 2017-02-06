require 'beaker-rspec/helpers/serverspec'
require 'beaker-rspec/spec_helper'
require 'beaker/puppet_install_helper'
require 'beaker/testmode_switcher/dsl'
require 'beaker/module_install_helper'

# automatically load any shared examples or contexts
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

run_puppet_install_helper
install_ca_certs unless ENV['PUPPET_INSTALL_TYPE'] =~ /pe/i

# Install iis module either from source or from staging forge if given correct env variables
unless ENV['MODULE_provision'] == 'no'
  if ENV.has_key?('BEAKER_FORGE_HOST') && ENV.has_key?('BEAKER_FORGE_API')
    module_version = ENV.has_key?('MODULE_VERSION') || '>= 0.1.0'
    install_module_from_forge_on(agents, 'puppetlabs-iis', module_version)
  else
    install_module_on(agents)
  end
end

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do
    unless ENV['BEAKER_TESTMODE'] == 'local' || ENV['BEAKER_provision'] == 'o'
      install_module_from_forge_on(agents, 'puppet/windowsfeature', '>= 2.0.0')
      pp = "windowsfeature { ['Web-WebServer','Web-Scripting-Tools']: ensure => present }"
      apply_manifest_on(agents, pp)
    end
  end
end

def beaker_opts
  @env ||= {
    acceptable_exit_codes: (0...256),
    debug: true,
    trace: true,
  }
end
