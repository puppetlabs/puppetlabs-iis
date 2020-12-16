# frozen_string_literal: true

require 'puppet_litmus'
require 'singleton'

# automatically load any shared examples or contexts
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do
    LitmusHelper.instance.run_shell('puppet module install puppetlabs/dism -v >= 1.2.0') unless ENV['TARGET_HOST'].nil? || ENV['TARGET_HOST'] == 'localhost'
    pp = "dism { ['IIS-WebServerRole','IIS-WebServer', 'IIS-WebServerManagementTools']: ensure => present }"
    LitmusHelper.instance.apply_manifest(pp)
  end
end

def module_fixtures
  @module_fixtures ||= File.join(Dir.pwd, 'spec\fixtures\modules')
end

def resource(res, name)
  if ENV['TARGET_HOST'].nil? || ENV['TARGET_HOST'] == 'localhost'
    LitmusHelper.instance.run_shell("puppet resource #{res} #{name} --modulepath #{module_fixtures}")
  else
    LitmusHelper.instance.run_shell("puppet resource #{res} #{name}")
  end
end

def target_host_facts
  facter_version = run_shell('facter --version').stdout.strip.split('.')[0]
  @target_host_facts ||= if facter_version =~ %r{4}
                           run_shell('facter --json --show-legacy').stdout.strip
                         else
                           run_shell('facter -p --json').stdout.strip
                         end
end

def encode_command(command)
  Base64.strict_encode64(command.encode('UTF-16LE'))
end

def interpolate_powershell(command)
  "powershell.exe -EncodedCommand #{encode_command(command)}"
end
