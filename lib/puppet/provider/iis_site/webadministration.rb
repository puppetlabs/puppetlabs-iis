require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

# When writing IIS PowerShell code for any of the methods below
# NEVER EVER use Get-Website without specifying -Name. As the number
# of sites on a server increases, Get-Website will take longer and longer
# to return. This will exponentially increase the total duration of your
# puppet run

Puppet::Type.type(:iis_site).provide(:webadministration, parent: Puppet::Provider::IIS_PowerShell) do
  desc "IIS Provider using the PowerShell WebAdministration module"

  confine    :iis_version     => ['8.0','8.5']
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
    inst_cmd = "Get-Website -Name '#{@resource[:name]}'"
    result   = self.class.run(inst_cmd)

    resp = result[:stdout]
    if resp.nil?
      return false
    else
      return true
    end
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

    return [] if result.nil? || result[:stdout].nil?

    site_json = JSON.parse(result[:stdout])
    return [] if site_json.nil?

    site_json = [site_json] if site_json.is_a?(Hash)
    return site_json.collect do |site|
      site_hash = {}

      site_hash[:ensure]               = site['state'].downcase
      site_hash[:name]                 = site['name']
      site_hash[:physicalpath]         = site['physicalpath']
      site_hash[:applicationpool]      = site['applicationpool']
      site_hash[:serverautostart]      = to_bool(site['serverautostart'])
      site_hash[:enabledprotocols]     = site['enabledprotocols']
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
