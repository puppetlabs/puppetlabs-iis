require 'puppet/util/feature'

def iis_compatible_versions
  ['7.5', '8.0', '8.5', '10.0']
end

def iis_installed_version
  Puppet.debug "Reading Registry for IIS Version"
  installed_version = nil
  begin
    require 'win32/registry'
    hklm        = Win32::Registry::HKEY_LOCAL_MACHINE
    reg_path    = 'SOFTWARE\Microsoft\InetStp'
    access_type = Win32::Registry::KEY_READ | 0x100
    reg_key     = 'VersionString'
    iis_version_text = ''
    hklm.open(reg_path, access_type) do |reg|
      iis_version_text = reg[reg_key]
    end
    if iis_version_text.match(/^Version (\d+\.\d+)$/)
      installed_version = $1
    end
    Puppet.debug "IIS Version: #{installed_version}"
  rescue Exception => e
    installed_version = nil
  end
  installed_version
end

def iis_compatible_version_installed?
  iis_compatible_versions.include? iis_installed_version
end

##

Puppet.features.add(:iis_compatible_version) do
  iis_compatible_version_installed?
end

# https://tickets.puppetlabs.com/browse/PUP-5985

Puppet.features.send :meta_def, 'iis_compatible_version' do
  name = :iis_compatible_version
  @results[name] = iis_compatible_version_installed? unless @results[name]
  @results[name]
end