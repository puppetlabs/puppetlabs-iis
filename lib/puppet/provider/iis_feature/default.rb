require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_feature).provide(:default, parent: Puppet::Provider::IIS_PowerShell) do
  desc 'IIS feature provider'

  require Pathname.new(__FILE__).dirname + '..' + '..' + '..' + 'puppet_x' + 'puppetlabs' + 'iis' + 'iis_features'
  include PuppetX::IIS::Features

  confine    feature: :pwshlib
  confine    operatingsystem: [:windows]
  defaultfor operatingsystem: :windows

  def self.powershell_path
    require 'ruby-pwsh'
    Pwsh::Manager.powershell_path
  rescue
    nil
  end

  commands powershell: powershell_path

  mk_resource_methods

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    raise Puppet::Error, "iis_feature can only be used to install IIS features. '#{resource[:name]}' is not an IIS feature" unless PuppetX::IIS::Features.iis_feature?(resource[:name])

    if @resource[:include_management_tools] == true && self.class.is_windows2008 == true
      raise Puppet::Error, 'include_management_tools can only be used with Windows 2012 and above'
    end

    cmd = []
    cmd << "Import-Module ServerManager; Add-WindowsFeature -Name #{resource[:name]}" if self.class.is_windows2008 == true
    cmd << "Install-WindowsFeature -Name #{resource[:name]} " if self.class.is_windows2008 == false
    cmd << '-IncludeAllSubFeature ' if @resource[:include_all_subfeatures] == true
    cmd << '-Restart ' if @resource[:restart] == true
    cmd << "-Source #{resource['source']} " if @resource[:source]
    cmd << '-IncludeManagementTools' if @resource[:include_management_tools] == true && self.class.is_windows2008 == false

    Puppet.debug "Powershell create command is '#{cmd}'"
    result = self.class.run(cmd.join)
    Puppet.debug "Powershell create response was '#{result}'"
  end

  def update
    Puppet.debug "Updating #{@resource[:name]}"
  end

  def destroy
    raise Puppet::Error, "iis_feature can only be used to install IIS features. '#{resource[:name]}' is not an IIS feature" unless PuppetX::IIS::Features.iis_feature?(resource[:name])

    cmd = []
    cmd << "Import-Module ServerManager; Remove-WindowsFeature -Name #{resource[:name]}" if self.class.is_windows2008 == true
    cmd << "Uninstall-WindowsFeature #{resource[:name]}" if self.class.is_windows2008 == false
    cmd << ' -Restart' if @resource[:restart] == true

    Puppet.debug "Powershell destroy command is '#{cmd}'"
    result = self.class.run(cmd.join)
    Puppet.debug "Powershell destroy response was '#{result}'"
  end

  def self.instances
    cmd = []
    cmd << 'Import-Module ServerManager; ' if is_windows2008 == true
    cmd << 'Get-WindowsFeature | Sort Name | Select Name,Installed | ConvertTo-Json -Depth 4'

    result = run(cmd.join)

    return [] if result.nil?

    json = parse_json_result(result[:stdout])
    return [] if json.nil?

    json.select { |feature| PuppetX::IIS::Features.iis_feature?(feature['Name']) }.map do |feature|
      feature_hash = {
        name: feature['Name'],
        ensure: (feature['Installed'] == true) ? :present : :absent,
      }

      new(feature_hash)
    end
  end

  def self.prefetch(resources)
    features = instances
    resources.keys.each do |name|
      if provider = features.find { |feature| name.casecmp(feature.name).zero? }
        resources[name].provider = provider
      end
    end
  end

  def self.is_windows2008
    os_major_version == '6.1'
  end

  def self.os_major_version
    if @os_major_version.nil?
      version = Facter.value(:kernelmajversion)
      @os_major_version = version.nil? ? nil : version
    end
    @os_major_version
  end
end
