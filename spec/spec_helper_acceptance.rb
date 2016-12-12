require 'beaker-rspec/helpers/serverspec'
require 'beaker-rspec/spec_helper'
require 'beaker/puppet_install_helper'
require 'beaker/testmode_switcher/dsl'

# automatically load any shared examples or contexts
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

run_puppet_install_helper

unless ENV['MODULE_provision'] == 'no'
  on default, "mkdir -p #{default['distmoduledir']}/iis"
  result = on default, "echo #{default['distmoduledir']}/iis"
  target = result.raw_output.chomp
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  %w(lib metadata.json).each do |file|
    scp_to default, "#{proj_root}/#{file}", target
  end
end

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Configure all nodes in nodeset
  c.before :suite do
    unless ENV['BEAKER_TESTMODE'] == 'local'
      unless ENV['BEAKER_provision'] == 'no'
        shell("/bin/touch #{default['puppetpath']}/hiera.yaml")
        # install iis
        on(agents, puppet("module install puppet/windowsfeature"))
        pp=<<-EOS
    $iis_features = ['Web-WebServer','Web-Scripting-Tools']

    windowsfeature { $iis_features:
      ensure => present,
    }
        EOS
        apply_manifest(pp)
      end
    end
  end
  c.after :suite do
    absent_files = 'file{["c:/services.txt","c:/process.txt","c:/try_success.txt","c:/catch_shouldntexist.txt","c:/try_shouldntexist.txt","c:/catch_success.txt"]: ensure => absent }'
    apply_manifest(absent_files)
  end
end

def beaker_opts
  @env ||= {
    debug: true,
    trace: true,
  }
end
