require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_application_pool).provide(:webadministration, parent: Puppet::Provider::IIS_PowerShell) do
  desc "IIS Application Pool provider using the PowerShell WebAdministration module"

  confine    :iis_version     => ['7.5','8.0', '8.5']
  confine    :operatingsystem => [ :windows ]
  defaultfor :operatingsystem => :windows

  commands :powershell => PuppetX::IIS::PowerShellCommon.powershell_path

  mk_resource_methods
  
  def create
    inst_cmd = "New-WebAppPool -Name \"#{@resource[:name]}\" -ErrorAction Stop"
    result   = self.class.run(inst_cmd)
    Puppet.err "Error creating apppool: #{result[:errormessage]}" unless result[:exitcode] == 0
    Puppet.err "Error creating apppool: #{result[:errormessage]}" unless result[:errormessage].nil?
  end

  def update
    inst_cmd = []

    inst_cmd << self.class.ps_script_content('_setapppool', @resource)
    
    @resource.properties.select{|rp| rp.name != :ensure && rp.name != :state }.each do |property|
      inst_cmd << "Invoke-AppCmd -ArgumentList 'set', 'apppool', #{@resource[:name]}, '/#{property.name.to_s}:#{property.value}';"
    end
    
    if !@resource[:state].nil?
      case @resource[:state]
      when 'Stopped'
        inst_cmd << "Stop-WebAppPool -Name \"#{@resource[:name]}\" -ErrorAction Stop"
      when 'Started'
        inst_cmd << "Start-WebAppPool -Name \"#{@resource[:name]}\" -ErrorAction Stop"
      end
    end
    
    inst_cmd = inst_cmd.join
    result   = self.class.run(inst_cmd)
    Puppet.err "Error updating apppool: #{result[:errormessage]}" unless result[:exitcode] == 0
    Puppet.err "Error updating apppool: #{result[:errormessage]}" unless result[:errormessage].nil?
  end

  def destroy
    inst_cmd = "Remove-WebAppPool -Name \"#{@resource[:name]}\" -ErrorAction Stop"
    result   = self.class.run(inst_cmd)
    Puppet.err "Error destroying apppool: #{result[:errormessage]}" unless result[:exitcode] == 0
    Puppet.err "Error destroying apppool: #{result[:errormessage]}" unless result[:errormessage].nil?
  end

  def self.prefetch(resources)
    pools = instances
    resources.keys.each do |pool|
      if provider = pools.find{ |s| s.name == pool }
        resources[pool].provider = provider
      end
    end
  end

  def self.instances
    inst_cmd = ps_script_content('_getapppools', @resource)
    result   = run(inst_cmd)
    return [] if result.nil?

    pool_json = self.parse_json_result(result[:stdout])
    return [] if pool_json.nil?

    pool_json.collect do |pool|
      pool_hash = {}

      pool_hash[:ensure]                = :present # pool['state'].downcase
      pool_hash[:name]                  = pool['name']
      pool_hash[:state]                 = pool['state']
      pool_hash[:managedpipelinemode]   = pool['managedpipelinemode']
      pool_hash[:managedruntimeversion] = pool['managedruntimeversion']

      new(pool_hash)
    end
  end
end
