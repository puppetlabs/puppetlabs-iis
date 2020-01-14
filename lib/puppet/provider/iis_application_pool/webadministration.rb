require File.join(File.dirname(__FILE__), '../../../puppet/provider/iis_powershell')

Puppet::Type.type(:iis_application_pool).provide(:webadministration, parent: Puppet::Provider::IIS_PowerShell) do
  desc 'IIS Application Pool provider using the PowerShell WebAdministration module'

  confine     feature: :pwshlib
  confine     feature: :iis_web_server
  confine     operatingsystem: [:windows]
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
    @resource[:ensure] == :present
  end

  def create
    Puppet.debug "Creating #{@resource[:name]}"
    inst_cmd = "New-WebAppPool -Name \"#{@resource[:name]}\" -ErrorAction Stop"
    result   = self.class.run(inst_cmd)
    Puppet.err "Error creating apppool: #{result[:errormessage]}" unless (result[:exitcode]).zero?
    Puppet.err "Error creating apppool: #{result[:errormessage]}" unless result[:errormessage].nil?
    @resource[:ensure] = :present
  end

  def update
    Puppet.debug "Updating #{@resource[:name]}"
    cmd = []

    @resource.properties.select { |rp| rp.name != :ensure && rp.name != :state }.each do |property|
      property_name = iis_properties[property.name.to_s]
      Puppet.debug "Changing #{property_name} to #{property.value}"
      if property.value.is_a?(Array)
        cmd << "Clear-ItemProperty -Path 'IIS:\\AppPools\\#{@resource[:name]}' -Name '#{property_name}'"
        property.value.each do |item|
          cmd << "New-ItemProperty -Path 'IIS:\\AppPools\\#{@resource[:name]}' -Name '#{property_name}' -Value @\{value=#{escape_value(item)}\}"
        end
      else
        cmd << "Set-ItemProperty -Path 'IIS:\\AppPools\\#{@resource[:name]}' -Name '#{property_name}' -Value #{escape_value(property.value)}"
      end
    end

    unless @resource[:state].nil?
      Puppet.debug "Changing #{@resource[:name]} to #{@resource[:state]}"
      case @resource[:state].downcase
      when :stopped
        cmd << "If((Get-WebAppPoolState -Name \"#{@resource[:name]}\").Value -ne 'Stopped'){Stop-WebAppPool -Name \"#{@resource[:name]}\" -ErrorAction Stop}"
      when :started
        cmd << "If((Get-WebAppPoolState -Name \"#{@resource[:name]}\").Value -ne 'Started'){Start-WebAppPool -Name \"#{@resource[:name]}\" -ErrorAction Stop}"
      end
    end

    cmd = cmd.join("\n")
    result = self.class.run(cmd)
    Puppet.err "Error updating apppool: #{result[:errormessage]}" unless (result[:exitcode]).zero?
    Puppet.err "Error updating apppool: #{result[:errormessage]}" unless result[:errormessage].nil?
  end

  def destroy
    Puppet.debug "Creating #{@resource[:name]}"
    inst_cmd = "Remove-WebAppPool -Name \"#{@resource[:name]}\" -ErrorAction Stop"
    result   = self.class.run(inst_cmd)
    Puppet.err "Error destroying apppool: #{result[:errormessage]}" unless (result[:exitcode]).zero?
    Puppet.err "Error destroying apppool: #{result[:errormessage]}" unless result[:errormessage].nil?

    @resource[:ensure] = :absent
  end

  def initialize(value = {})
    super(value)
    @property_flush = {}
  end

  def self.prefetch(resources)
    pools = instances
    resources.keys.each do |pool|
      if provider = pools.find { |s| s.name == pool }
        resources[pool].provider = provider
      end
    end
  end

  def self.instances
    inst_cmd = ps_script_content('_getapppools', @resource)
    result   = run(inst_cmd)
    return [] if result.nil?

    pool_json = parse_json_result(result[:stdout])
    return [] if pool_json.nil?

    pool_json.map do |pool|
      pool_hash = {}

      pool_hash[:ensure] = :present
      pool_hash[:name]   = pool['name']
      pool_hash[:state]  = pool['state'].to_s.downcase

      pool_hash[:auto_start]                    = pool['auto_start'].to_s.downcase
      pool_hash[:clr_config_file]               = pool['clr_config_file']
      pool_hash[:enable32_bit_app_on_win64]     = pool['enable32_bit_app_on_win64'].to_s.downcase
      pool_hash[:enable_configuration_override] = pool['enable_configuration_override'].to_s.downcase
      pool_hash[:managed_pipeline_mode]         = pool['managed_pipeline_mode']
      pool_hash[:managed_runtime_version]       = pool['managed_runtime_version'].nil? ? '' : pool['managed_runtime_version']
      pool_hash[:pass_anonymous_token]          = pool['pass_anonymous_token'].to_s.downcase
      pool_hash[:start_mode]                    = pool['start_mode']
      pool_hash[:queue_length]                  = pool['queue_length']

      pool_hash[:cpu_action]                       = pool['cpu_action']
      pool_hash[:cpu_limit]                        = pool['cpu_limit']
      pool_hash[:cpu_reset_interval]               = pool['cpu_reset_interval']
      pool_hash[:cpu_smp_affinitized]              = pool['cpu_smp_affinitized'].to_s.downcase
      pool_hash[:cpu_smp_processor_affinity_mask]  = pool['cpu_smp_processor_affinity_mask']
      pool_hash[:cpu_smp_processor_affinity_mask2] = pool['cpu_smp_processor_affinity_mask2']

      pool_hash[:identity_type]              = pool['identity_type']
      pool_hash[:idle_timeout]               = pool['idle_timeout']
      pool_hash[:idle_timeout_action]        = pool['idle_timeout_action']
      pool_hash[:load_user_profile]          = pool['load_user_profile'].to_s.downcase
      pool_hash[:log_event_on_process_model] = pool['log_event_on_process_model']
      pool_hash[:logon_type]                 = pool['logon_type']
      pool_hash[:manual_group_membership]    = pool['manual_group_membership'].to_s.downcase
      pool_hash[:max_processes]              = pool['max_processes']
      pool_hash[:pinging_enabled]            = pool['pinging_enabled'].to_s.downcase
      pool_hash[:ping_interval]              = pool['ping_interval']
      pool_hash[:ping_response_time]         = pool['ping_response_time']
      pool_hash[:set_profile_environment]    = pool['set_profile_environment'].to_s.downcase
      pool_hash[:shutdown_time_limit]        = pool['shutdown_time_limit']
      pool_hash[:startup_time_limit]         = pool['startup_time_limit']
      pool_hash[:user_name]                  = pool['user_name']
      pool_hash[:password]                   = pool['password']

      pool_hash[:orphan_action_exe]                 = pool['orphan_action_exe']
      pool_hash[:orphan_action_params]              = pool['orphan_action_params']
      pool_hash[:orphan_worker_process]             = pool['orphan_worker_process'].to_s.downcase
      pool_hash[:load_balancer_capabilities]        = pool['load_balancer_capabilities']
      pool_hash[:rapid_fail_protection]             = pool['rapid_fail_protection'].to_s.downcase
      pool_hash[:rapid_fail_protection_interval]    = pool['rapid_fail_protection_interval']
      pool_hash[:rapid_fail_protection_max_crashes] = pool['rapid_fail_protection_max_crashes']
      pool_hash[:auto_shutdown_exe]                 = pool['auto_shutdown_exe']
      pool_hash[:auto_shutdown_params]              = pool['auto_shutdown_params']

      pool_hash[:disallow_overlapping_rotation]      = pool['disallow_overlapping_rotation'].to_s.downcase
      pool_hash[:disallow_rotation_on_config_change] = pool['disallow_rotation_on_config_change'].to_s.downcase
      pool_hash[:log_event_on_recycle]               = pool['log_event_on_recycle']
      pool_hash[:restart_memory_limit]               = pool['restart_memory_limit']
      pool_hash[:restart_private_memory_limit]       = pool['restart_private_memory_limit']
      pool_hash[:restart_requests_limit]             = pool['restart_requests_limit']
      pool_hash[:restart_time_limit]                 = pool['restart_time_limit']
      pool_hash[:restart_schedule]                   = pool['restart_schedule'].to_s.split(' ')

      new(pool_hash)
    end
  end

  private

  def iis_properties
    # most of these are found with appcmd list apppool /text:*
    iis_properties = {
      # misc
      'auto_start'                    => 'autoStart',
      'clr_config_file'               => 'CLRConfigFile',
      'enable32_bit_app_on_win64'     => 'enable32BitAppOnWin64',
      'enable_configuration_override' => 'enableConfigurationOverride',
      'managed_pipeline_mode'         => 'managedPipelineMode',
      'managed_runtime_loader'        => 'managedRuntimeLoader',
      'managed_runtime_version'       => 'managedRuntimeVersion',
      'pass_anonymous_token'          => 'passAnonymousToken',
      'start_mode'                    => 'startMode',
      'queue_length'                  => 'queueLength',

      # cpu related
      'cpu_action'                       => 'cpu.action',
      'cpu_limit'                        => 'cpu.limit',
      'cpu_reset_interval'               => 'cpu.resetInterval',
      'cpu_smp_affinitized'              => 'cpu.smpAffinitized',
      'cpu_smp_processor_affinity_mask'  => 'cpu.smpProcessorAffinityMask',
      'cpu_smp_processor_affinity_mask2' => 'cpu.smpProcessorAffinityMask2',

      # processmodel related
      'identity_type'              => 'processModel.identityType',
      'idle_timeout'               => 'processModel.idleTimeout',
      'idle_timeout_action'        => 'processModel.idleTimeoutAction',
      'load_user_profile'          => 'processModel.loadUserProfile',
      'log_event_on_process_model' => 'processModel.logEventOnProcessModel',
      'logon_type'                 => 'processModel.logonType',
      'manual_group_membership'    => 'processModel.manualGroupMembership',
      'max_processes'              => 'processModel.maxProcesses',
      'pinging_enabled'            => 'processModel.pingingEnabled',
      'ping_interval'              => 'processModel.pingInterval',
      'ping_response_time'         => 'processModel.pingResponseTime',
      'set_profile_environment'    => 'processModel.setProfileEnvironment',
      'shutdown_time_limit'        => 'processModel.shutdownTimeLimit',
      'startup_time_limit'         => 'processModel.startupTimeLimit',
      'user_name'                  => 'processModel.userName',
      'password'                   => 'processModel.password',

      'orphan_action_exe'          => 'failure.orphanActionExe',
      'orphan_action_params'       => 'failure.orphanActionParams',
      'orphan_worker_process'      => 'failure.orphanWorkerProcess',

      # rapid-fail
      'load_balancer_capabilities'        => 'failure.loadBalancerCapabilities',
      'rapid_fail_protection'             => 'failure.rapidFailProtection',
      'rapid_fail_protection_interval'    => 'failure.rapidFailProtectionInterval',
      'rapid_fail_protection_max_crashes' => 'failure.rapidFailProtectionMaxCrashes',
      'auto_shutdown_exe'                 => 'failure.autoShutdownExe',
      'auto_shutdown_params'              => 'failure.autoShutdownParams',

      # recycle
      'disallow_overlapping_rotation'      => 'recycling.disallowOverlappingRotation',
      'disallow_rotation_on_config_change' => 'recycling.disallowRotationOnConfigChange',
      'log_event_on_recycle'               => 'recycling.logEventOnRecycle',
      'restart_memory_limit'               => 'recycling.periodicRestart.memory',
      'restart_private_memory_limit'       => 'recycling.periodicRestart.privateMemory',
      'restart_requests_limit'             => 'recycling.periodicRestart.requests',
      'restart_time_limit'                 => 'recycling.periodicRestart.time',
      'restart_schedule'                   => 'recycling.periodicRestart.schedule',
    }

    iis_properties
  end

  def escape_value(value)
    if number?(value)
      value
    else
      "'#{value.to_s.gsub("'", "''")}\'"
    end
  end

  def number?(value)
    value.respond_to?(:to_i) ? value.to_s == value.to_i.to_s : false
  end
end
