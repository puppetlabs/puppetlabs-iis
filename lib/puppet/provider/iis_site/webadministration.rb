require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

# When writing IIS PowerShell code for any of the methods below
# NEVER EVER use Get-Website without specifying -Name. As the number
# of sites on a server increases, Get-Website will take longer and longer
# to return. This will exponentially increase the total duration of your
# puppet run

Puppet::Type.type(:iis_site).provide(:webadministration, parent: Puppet::Provider::IIS_PowerShell) do
  desc "IIS Provider using the PowerShell WebAdministration module"

  confine    :iis_version     => ['7.5','8.0','8.5']
  confine    :operatingsystem => [:windows ]
  defaultfor :operatingsystem => :windows

  commands :powershell => PuppetX::IIS::PowerShellCommon.powershell_path

  mk_resource_methods

  def create
    cmd = []

    cmd << self.class.ps_script_content('_newwebsite', @resource)

    inst_cmd = cmd.join

    result = self.class.run(inst_cmd)

    Puppet.err "Error creating website: #{result[:errormessage]}" unless result[:exitcode] == 0
    Puppet.err "Error creating website: #{result[:errormessage]}" unless result[:errormessage].nil?

    return exists?
  end

  def update
    cmd = []

    cmd << self.class.ps_script_content('_setwebsite', @resource)

    cmd << self.class.ps_script_content('trysetitemproperty', @resource)

    cmd << self.class.ps_script_content('generalproperties', @resource)

    cmd << self.class.ps_script_content('bindingproperty', @resource)

    cmd << self.class.ps_script_content('logproperties', @resource)

    cmd << self.class.ps_script_content('serviceautostartprovider', @resource)

    inst_cmd = cmd.join

    result = self.class.run(inst_cmd)

    Puppet.err "Error updating website: #{result[:errormessage]}" unless result[:exitcode] == 0
    Puppet.err "Error updating website: #{result[:errormessage]}" unless result[:errormessage].nil?

    return exists?
  end

  def destroy
    inst_cmd = "Remove-Website -Name \"#{@resource[:name]}\" -ErrorAction Stop"
    result   = self.class.run(inst_cmd)
    Puppet.err "Error destroying website: #{result[:errormessage]}" unless result[:exitcode] == 0
    Puppet.err "Error destroying website: #{result[:errormessage]}" unless result[:errormessage].nil?
    return exists?
  end

  def exists?
    inst_cmd = "If (Test-Path -Path 'IIS:\\sites\\#{@resource[:name]}') { exit 0 } else { exit 255 }"

    result   = self.class.run(inst_cmd)

    return result[:exitcode] == 0
  end

  def start
    create if ! exists?
    @resource[:ensure]  = 'started'

    inst_cmd = "Start-Website -Name \"#{@resource[:name]}\""
    result   = self.class.run(inst_cmd)
    Puppet.err "Error starting website: #{result[:errormessage]}" unless result[:errormessage].nil?

    resp     = result[:stdout]
    if resp.nil?
      return true
    else
      return false
    end
  end

  def stop
    create if ! exists?
    @resource[:ensure] = 'stopped'

    inst_cmd = "Stop-Website -Name \"#{@resource[:name]}\""
    result   = self.class.run(inst_cmd)
    Puppet.err "Error stopping website: #{result[:errormessage]}" unless result[:errormessage].nil?

    resp = result[:stdout]
    if resp.nil?
      return true
    else
      return false
    end
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    sites = instances
    resources.keys.each do |site|
      if !sites.nil? && provider = sites.find { |s| s.name == site }
        resources[site].provider = provider
      end
    end
  end

  def self.instances
    inst_cmd = ps_script_content('_getwebsites', @resource)
    result   = run(inst_cmd)
    return [] if result.nil?

    site_json = self.parse_json_result(result[:stdout])
    return [] if site_json.nil?

    return site_json.collect do |site|
      site_hash = {}

      # In PowerShell 2.0, empty strings come in as nil which then fail insync? tests.
      # Convert nil's to empty strings for all properties which we know are String types
      ['name','physicalpath','applicationpool','hostheader','state','serverautostart','enabledprotocols',
       'logformat','logpath','logperiod','logtruncatesize','loglocaltimerollover','logextfileflags'].each do |setting|
        site[setting] = '' if site[setting].nil?
      end
      site['bindings'] = [] if site['bindings'].nil?
      site['bindings'].each do |binding|
        # "The sslFlags attribute is only set when the protocol is https."
        binding.delete('sslflags') unless binding['protocol'] == 'https'
        # "The CertificateHash property is available only when the protocol
        # identifier defined by the Protocol property is "https". An attempt to
        # get or set the CertificateHash property for a binding with a protocol
        # of "http" will raise an error."
        binding.delete('certificatehash') unless binding['protocol'] == 'https'
        binding.delete('certificatestorename') unless binding['protocol'] == 'https'
      end

      site_hash[:ensure]               = site['state'].downcase
      site_hash[:name]                 = site['name']
      site_hash[:physicalpath]         = site['physicalpath']
      site_hash[:applicationpool]      = site['applicationpool']
      site_hash[:serverautostart]      = to_bool(site['serverautostart'])
      site_hash[:enabledprotocols]     = site['enabledprotocols']
      site_hash[:bindings]             = site['bindings']
      site_hash[:logpath]              = site['logpath']
      site_hash[:logperiod]            = site['logperiod']
      site_hash[:logtruncatesize]      = site['logtruncatesize']
      site_hash[:loglocaltimerollover] = to_bool(site['loglocaltimerollover'])
      site_hash[:logformat]            = site['logformat']
      site_hash[:logflags]             = site['logextfileflags'].split(/,\s*/).sort

      new(site_hash)
    end
  end

  def self.to_bool(value)
    return :true   if value == true   || value =~ (/(true|t|yes|y|1)$/i)
    return :false  if value == false  || value =~ (/(^$|false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{value}\"")
  end
end
