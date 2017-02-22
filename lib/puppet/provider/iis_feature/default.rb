require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_feature).provide(:default, parent: Puppet::Provider::IIS_PowerShell) do
  desc "IIS feature provider"

  confine    :operatingsystem  => [ :windows ]
  defaultfor :operatingsystem  => :windows

  commands :powershell => PuppetX::IIS::PowerShellCommon.powershell_path

  mk_resource_methods

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    if iis_installable_features.includes?(@resource[:name])
      raise Puppet::Error, "iis_feature can only be used to install IIS features. '#{resource[:name]}' is not an IIS feature"
    end

    if @resource[:include_management_tools] == true && self.class.is_windows2008 == true
      raise Puppet::Error, 'include_management_tools can only be used with Windows 2012 and above'
    end

    cmd = []
    cmd << "Import-Module ServerManager; Add-WindowsFeature #{resource[:name]}" if self.class.is_windows2008 == true
    cmd << "Install-WindowsFeature #{resource[:name]}" if self.class.is_windows2008 == false
    cmd << '-IncludeAllSubFeature' if @resource[:include_all_subfeatures] == true
    cmd << '-Restart' if @resource[:restart] == true
    cmd << "-Source #{resource['source']}" if @resource[:source] == false
    cmd << '-IncludeManagementTools' if @resource[:include_management_tools] == true && self.class.is_windows2008 == false

    Puppet.debug "Powershell create command is '#{cmd}'"
    result = self.class.run(cmd.join)
    Puppet.debug "Powershell create response was '#{result}'"
  end

  def destroy
    if iis_installable_features.includes?(@resource[:name])
      raise Puppet::Error, "iis_feature can only be used to uninstall IIS features. '#{resource[:name]}' is not an IIS feature"
    end

    cmd = []
    cmd << "Import-Module ServerManager; Remove-WindowsFeature #{resource[:name]}" if self.class.is_windows2008 == true
    cmd << "Uninstall-WindowsFeature #{resource[:name]}" if self.class.is_windows2008 == false
    cmd << '-Restart' if @resource[:restart] == true

    Puppet.debug "Powershell destroy command is '#{cmd}'"
    result = self.class.run(cmd.join)
    Puppet.debug "Powershell destroy response was '#{result}'"
  end

  def self.instances
    cmd = []
    cmd << 'Import-Module ServerManager; ' if self.is_windows2008 == true
    cmd << 'Get-WindowsFeature | ConvertTo-Json -Depth 4'
    
    result = self.run(cmd.join)
    
    return [] if result.nil?

    json = self.parse_json_result(result[:stdout])
    return [] if json.nil?

    json.collect do |feature|
      feature_hash = {}

      feature_hash[:ensure] = feature['Installed'] == false ? :absent : :present
      feature_hash[:name]   = feature['Name']
      
      new(feature_hash)
    end
  end

  def self.prefetch(resources)
    features = instances
    resources.keys.each do |name|
      if provider = features.find { |feature| feature.name.downcase == name.downcase }
        resources[name].provider = provider
      end
    end
  end
  
  def self.is_windows2008
    self.os_major_version == '6.1'
  end

  def self.os_major_version
    if @os_major_version.nil?
      version = Facter.value(:kernelmajversion)
      @os_major_version = version.nil? ? nil : version
    end
    @os_major_version
  end

  def iis_installable_features
    # Note this code uses an array of the latest IIS features available to
    # install, but does not keep track of which subset is available in a given
    # IIS distribution. We could have kept track but since there are only a
    # handful of added features from 7.5 to 8.5, it was thought it would be
    # easier to have one array to check rather than keep a seperate list per
    # IIS version. In short, we defer to the tooling to tell us what feature is
    # present in which IIS version and only keep track of the larger list.
    features = [
      'Web-App-Dev',
      'Web-AppInit',
      'Web-Application-Proxy',
      'Web-ASP',
      'Web-Asp-Net',
      'Web-Asp-Net45',
      'Web-Basic-Auth',
      'Web-Cert-Auth',
      'Web-CertProvider',
      'Web-CGI',
      'Web-Client-Auth',
      'Web-Common-Http',
      'Web-Custom-Logging',
      'Web-DAV-Publishing',
      'Web-Default-Doc',
      'Web-Digest-Auth',
      'Web-Dir-Browsing',
      'Web-Dyn-Compression',
      'Web-Filtering',
      'Web-Ftp-Ext',
      'Web-Ftp-Server',
      'Web-Ftp-Service',
      'Web-Health',
      'Web-Http-Errors',
      'Web-Http-Logging',
      'Web-Http-Redirect',
      'Web-Http-Tracing',
      'Web-Includes',
      'Web-IP-Security',
      'Web-ISAPI-Ext',
      'Web-ISAPI-Filter',
      'Web-Lgcy-Mgmt-Console',
      'Web-Lgcy-Scripting',
      'Web-Log-Libraries',
      'Web-Metabase',
      'Web-Mgmt-Compat',
      'Web-Mgmt-Console',
      'Web-Mgmt-Service',
      'Web-Mgmt-Tools',
      'Web-Net-Ext',
      'Web-Net-Ext45',
      'Web-ODBC-Logging',
      'Web-Performance',
      'Web-Request-Monitor',
      'Web-Scripting-Tools',
      'Web-Security',
      'Web-Server',
      'Web-Stat-Compression',
      'Web-Static-Content',
      'Web-Url-Auth',
      'Web-WebServer',
      'Web-WebSockets',
      'Web-WHC',
      'Web-Windows-Auth',
      'Web-WMI',
    ]
    features
  end
end
