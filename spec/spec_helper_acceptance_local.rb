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
  facts = LitmusHelper.instance.run_bolt_task('facts')
  results = facts[:result]

  puts "facts ****************************" + facts.inspect
  puts "results ****************************" + results.inspect

  @target_host_facts ||= results
end

def encode_command(command)
  Base64.strict_encode64(command.encode('UTF-16LE'))
end

def interpolate_powershell(command)
  "powershell.exe -EncodedCommand #{encode_command(command)}"
end
