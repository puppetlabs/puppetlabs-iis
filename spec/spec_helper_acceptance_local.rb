# frozen_string_literal: true

require 'puppet_litmus'
require 'singleton'

# automatically load any shared examples or contexts
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

# This method allows a block to be passed in and if an exception is raised
# that matches the 'error_matcher' matcher, the block will wait a set number
# of seconds before retrying.
# Params:
# - max_retry_count - Max number of retries
# - retry_wait_interval_secs - Number of seconds to wait before retry
# - error_matcher - Matcher which the exception raised must match to allow retry
# Example Usage:
# retry_on_error_matching(3, 5, /OpenGPG Error/) do
#   apply_manifest(pp, :catch_failures => true)
# end
def retry_on_error_matching(max_retry_count = 3, retry_wait_interval_secs = 5, error_matcher = nil)
  try = 0
  begin
    try += 1
    yield
  rescue StandardError => e
    raise unless try < max_retry_count && (error_matcher.nil? || e.message =~ error_matcher)

    sleep retry_wait_interval_secs
    retry
  end
end

RSpec.configure do |c|
  # Configure all nodes in nodeset
  c.before :suite do
    # Install IIS and required features on the target host
    unless ENV['TARGET_HOST'].nil? || ENV['TARGET_HOST'] == 'localhost'
      LitmusHelper.instance.run_shell('Install-WindowsFeature -name Web-Server -IncludeManagementTools')
      LitmusHelper.instance.run_shell('Install-WindowsFeature -Name Web-HTTP-Errors')
      result = LitmusHelper.instance.run_shell('(Enable-WindowsOptionalFeature -Online -FeatureName IIS-WebServerRole -NoRestart).RestartNeeded')

      if result.stdout.split("\r\n").last == 'True'
        puts 'VM need reboot, hence doing force reboot'
        LitmusHelper.instance.run_shell('Restart-Computer -Force')
      end
    end

    # waiting for VM restart to complete and comes in running state
    retry_on_error_matching(120, 5, %r{.*}) do
      puts 'waiting for VM to restart..'
      LitmusHelper.instance.run_shell('ls') # random command to check connectivity to litmus host
    end
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
  @target_host_facts ||= if facter_version.include?('4')
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
