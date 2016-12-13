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

    site_json = JSON.parse(text)
    site_json = [site_json] if site_json.is_a?(Hash)
    site_json.collect do |site|
      site_hash = {}

      site_hash[:ensure] = site['state'].downcase
      site_hash[:name]   = site['name']
      site_hash[:state]   = site['state']
      site_hash[:managedPipelineMode]   = site['managedPipelineMode']
      site_hash[:managedRuntimeVersion]   = site['managedRuntimeVersion']

      new(site_hash)
    end
    []
  end
end
