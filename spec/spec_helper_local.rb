# frozen_string_literal: true

dir = __dir__
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'puppet'
require 'pathname'

require 'tmpdir'
require 'fileutils'

# automatically load any shared examples or contexts
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

if Puppet.features.microsoft_windows?
  require 'puppet/util/windows/security'

  def take_ownership(path)
    path = path.tr('/', '\\')
    output = `takeown.exe /F #{path} /R /A /D Y 2>&1`
    return unless $CHILD_STATUS != 0 # check if the child process exited cleanly.

    puts "#{path} got error #{output}"
  end

  def installed_powershell_major_version
    provider = Puppet::Type.type(:iis_site).provider(:webadministration)

    begin
      psversion = provider.powershell_version.split('.').first
      # psversion = `#{powershell} -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -Command \"$PSVersionTable.PSVersion.Major.ToString()\"`.chomp!.to_i
      puts "PowerShell major version number is #{psversion}"
    rescue StandardError
      puts 'Unable to determine PowerShell version'
      psversion = -1
    end
    psversion
  end
end

RSpec.configure do |config|
  tmpdir = Dir.mktmpdir('rspecrun_iis')
  oldtmpdir = Dir.tmpdir
  ENV['TMPDIR'] = tmpdir

  config.after :suite do
    # return to original tmpdir
    ENV['TMPDIR'] = oldtmpdir
    take_ownership(tmpdir) if Puppet::Util::Platform.windows?
    FileUtils.rm_rf(tmpdir)
  end
end
