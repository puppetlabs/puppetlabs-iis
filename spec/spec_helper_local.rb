dir = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.join(dir, 'lib')

require 'puppet'
require 'pathname'

require 'tmpdir'
require 'fileutils'

# automatically load any shared examples or contexts
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

if Puppet.features.microsoft_windows?
  require 'puppet/util/windows/security'

  def take_ownership(path)
    path = path.gsub('/', '\\')
    output = %x(takeown.exe /F #{path} /R /A /D Y 2>&1)
    if $? != 0 #check if the child process exited cleanly.
      puts "#{path} got error #{output}"
    end
  end

  def get_powershell_major_version()
    provider = Puppet::Type.type(:iis_site).provider(:webadministration)

    begin
      psversion = provider.powershell_version.split(".").first
      # psversion = `#{powershell} -NoProfile -NonInteractive -NoLogo -ExecutionPolicy Bypass -Command \"$PSVersionTable.PSVersion.Major.ToString()\"`.chomp!.to_i
      puts "PowerShell major version number is #{psversion}"
    rescue
      puts "Unable to determine PowerShell version"
      psversion = -1
    end
    psversion
  end
end

RSpec.configure do |config|
  tmpdir = Dir.mktmpdir("rspecrun_iis")
  oldtmpdir = Dir.tmpdir()
  ENV['TMPDIR'] = tmpdir

  config.after :suite do
    # return to original tmpdir
    ENV['TMPDIR'] = oldtmpdir
    if Puppet::Util::Platform.windows?
      take_ownership(tmpdir)
    end
    FileUtils.rm_rf(tmpdir)
  end
end
