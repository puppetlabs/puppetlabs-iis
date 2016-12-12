require 'puppet/provider/iis_powershell'

Puppet::Type.type(:iis_application_pool).provide(:webadministration, parent: Puppet::Provider::IIS_PowerShell) do
  desc "IIS Application Pool provider using the PowerShell WebAdministration module"

  confine    :iis_version     => ['8.0', '8.5']
  confine    :operatingsystem => [ :windows ]
  defaultfor :operatingsystem => :windows

  commands :powershell => PuppetX::IIS::PowerShellCommon.powershell_path

  mk_resource_methods

  def create
  end

  def update
  end

  def destroy
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    sites = instances
    resources.keys.each do |site|
      if provider = sites.find{ |s| s.name == site }
        resources[site].provider = provider
      end
    end
  end

  def self.instances
    inst_cmd = ps_script_content('_getapppools', @resource)
    result   = run(inst_cmd)
    text     = result[:stdout]

    puts text

    # site_json = JSON.parse(text)
    # site_json = [site_json] if site_json.is_a?(Hash)
    # site_json.collect do |site|
    #   site_hash = {}
    #
    #   site_hash[:ensure]               = site['state'].downcase
    #   site_hash[:name]                 = site['name']
    #   site_hash[:physicalpath]         = site['physicalpath']
    #   site_hash[:applicationpool]      = site['applicationpool']
    #   site_hash[:serverautostart]      = to_bool(site['serverautostart'].downcase) unless site['serverautostart'].empty?
    #   site_hash[:enabledprotocols]     = site['enabledprotocols']
    #   site_hash[:logpath]              = site['logpath']
    #   site_hash[:logperiod]            = site['logperiod']
    #   site_hash[:logtruncatesize]      = site['logtruncatesize']
    #   site_hash[:loglocaltimerollover] = to_bool(site['loglocaltimerollover'].downcase) unless site['loglocaltimerollover'].empty?
    #   site_hash[:logformat]            = site['logformat']
    #   site_hash[:logflags]             = site['logextfileflags']
    #
    #   new(site_hash)
    # end
    []
  end
end
