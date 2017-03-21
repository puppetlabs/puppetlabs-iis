require 'puppetlabs_spec_helper/module_spec_helper'

if Puppet::Util::Package.versioncmp(Puppet.version, '4.5.0') >= 0
  RSpec.configure do |c|
    c.mock_with :rspec
    c.before :each do
      Puppet.settings[:strict] = :error
    end
  end
else
  RSpec.configure do |c|
    c.mock_with :rspec
  end
end

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
    provider = Puppet::Type.type(:iis_powershell)
    
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

# put local configuration and setup into spec_helper_local
begin
  require 'spec_helper_local'
rescue LoadError
end
