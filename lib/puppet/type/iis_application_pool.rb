require 'puppet/parameter/boolean'
require_relative '../../puppet_x/puppetlabs/iis/property/string'
require_relative '../../puppet_x/puppetlabs/iis/property/positive_integer'
require_relative '../../puppet_x/puppetlabs/iis/property/timeformat'

Puppet::Type.newtype(:iis_application_pool) do
  @doc = "Manage an IIS application pool."
  # https://www.iis.net/configreference/system.applicationhost/applicationpools/applicationpooldefaults?showTreeNavigation=true

  newproperty(:ensure) do
    desc "Specifies whether an application pool should be present or absent. If `state` is
      not specified, the application pool will be created and left in the default started state."

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
    
    defaultto :present
  end
  
  newparam(:name, :namevar => true, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "The unique name of the ApplicationPool."
    validate do |value|
      super value
      if value.nil? or value.empty?
        raise ArgumentError, "A non-empty #{self.name.to_s} must be specified."
      end
      fail("#{self.name.to_s} should be less than 64 characters") unless value.length < 64
      fail("#{self.name.to_s} is not a valid web site name") unless value =~ /^[a-zA-Z0-9\-\_'\s]+$/
    end
  end

  newproperty(:state) do
    desc "The state of the ApplicationPool. By default, a newly created application pool will be started"
    newvalues(:Started,:Stopped,:started,:stopped)
  end

  newproperty(:auto_start, :boolean => true) do
    desc "When true, indicates to the World Wide Web Publishing Service (W3SVC) that the application pool should be automatically started when it is created or when IIS is started."
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:clr_config_file, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "Specifies the .NET configuration file for the application pool"
  end

  newproperty(:enable32_bit_app_on_win64, :boolean => true) do
    desc "When true, enables a 32-bit application to run on a computer that runs a 64-bit version of Windows"
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:enable_configuration_override, :boolean => true) do
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:managed_pipeline_mode) do
    desc "Specifies the request-processing mode that is used to process requests for managed content. First letter has to be capitalized."
    newvalues(:Integrated,:Classic)
  end

  newproperty(:managed_runtime_loader, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "Specifies the managed loader to use for pre-loading the the application pool"
  end

  newproperty(:managed_runtime_version) do
    desc "Specifies the .NET Framework version to be used by the application pool"
    newvalues('v1.1','v2.0','v4.0')
  end

  newproperty(:pass_anonymous_token, :boolean => true) do
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:start_mode) do
    desc "Specifies the startup type for the application pool"
    newvalues(:OnDemand, :AlwaysRunning)
  end

  newproperty(:queue_length, :parent => PuppetX::PuppetLabs::IIS::Property::PositiveInteger) do
    desc "Indicates to HTTP.sys how many requests to queue for an application pool before rejecting future requests.
          When the value set for this property is exceeded, IIS rejects subsequent requests with a 503 error.
          If the loadBalancerCapabilities setting is true, the connection is closed instead of rejecting requests
          with a 503. For more information about loadBalancerCapabilities, see
          https://www.iis.net/configreference/system.applicationhost/applicationPools/add/failure"
    validate do |value|
      super value
      fail "#{self.name.to_s} should be greater than 10" unless value.to_i > 10
      fail "#{self.name.to_s} should be less than or equal to 65535" unless value.to_i <= 65535
    end
  end

  newproperty(:cpu_action) do
    desc "Configures the action that IIS takes when a worker process exceeds its configured CPU limit.
    The action attribute is configured on a per-application pool basis"
    newvalues(:NoAction, :KillW3wp, :Throttle, :ThrottleUnderLoad)
  end

  newproperty(:cpu_limit, :parent => PuppetX::PuppetLabs::IIS::Property::PositiveInteger) do
    desc "Configures the maximum percentage of CPU time (in 1/1000ths of one percent) that the worker processes
          in an application pool are allowed to consume over a period of time as indicated by the resetInterval
          attribute. If the limit set by the limit attribute is exceeded, an event is written to the event log
          and an optional set of events can be triggered. These optional events are determined by the action attribute."
    validate do |value|
      super value
      fail "#{self.name.to_s} should be less than or equal to 100000" unless value.to_i <= 100000
    end
  end

  newproperty(:cpu_reset_interval, :parent => PuppetX::PuppetLabs::IIS::Property::TimeFormat) do
    desc "Specifies the reset period (in minutes) for CPU monitoring and throttling limits on an application pool.
          When the number of minutes elapsed since the last process accounting reset equals the number specified by
          this property, IIS resets the CPU timers for both the logging and limit intervals.
          
          Important: The resetInterval value must be greater than the time between logging operations,
          otherwise IIS will reset counters before logging has occurred, and process accounting will not occur.
          
          Note: Because process accounting in IIS uses Windows job objects to monitor CPU times for the whole process,
          process accounting will only log and throttle applications that are isolated in a separate process from IIS."
  end

  newproperty(:cpu_smp_affinitized, :boolean => true) do
    desc "Specifies whether a particular worker process assigned to an application pool should also be assigned
          to a given CPU. This property is used together with the `smpProcessorAffinityMask` and
          `smpProcessorAffinityMask2` attributes."
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:cpu_smp_processor_affinity_mask, :parent => PuppetX::PuppetLabs::IIS::Property::PositiveInteger) do
    desc "Specifies the hexadecimal processor mask for multi-processor computers, which indicates to which CPU
    the worker processes in an application pool should be bound. Before this property takes effect, the smpAffinitized
    attribute must be set to true for the application pool.

    Note: On 64-bit computers, the smpProcessorAffinityMask attribute contains the low-order DWORD for the processor mask,
    and the smpProcessorAffinityMask2 attribute contains the high-order DWORD for the processor mask. On 32-bit computers,
    the smpProcessorAffinityMask2 attribute has no effect.

    If you set the value to 1 (which corresponds to 00000000000000001 in binary), the worker processes in 
    an application pool run on only the first processor. If you set the value to 2 (which corresponds to 0000000000000010
    in binary), the worker processes run on only the second processor. If you set the value to 3 (which corresponds
    to 0000000000000011 in binary) the worker processes run on both the first and second processors.

    Note: Do not set this property to 0. Doing so disables symmetric multiprocessing (SMP) affinity and 
    creates an error condition. This means that processes running on one CPU will not remain affiliated with that CPU
    throughout their lifetime."
  end

  newproperty(:cpu_smp_processor_affinity_mask2, :parent => PuppetX::PuppetLabs::IIS::Property::PositiveInteger) do
    desc "Specifies the high-order DWORD hexadecimal processor mask for 64-bit multi-processor computers,
          which indicates to which CPU the worker processes in an application pool should be bound.
          Before this property takes effect, the smpAffinitized attribute must be set to true for the application pool.

          Note: On 64-bit computers, the smpProcessorAffinityMask attribute contains the low-order DWORD
          for the processor mask, and the smpProcessorAffinityMask2 attribute contains the high-order DWORD
          for the processor mask. On 32-bit computers, the smpProcessorAffinityMask2 attribute has no effect."
  end

  newproperty(:identity_type) do
    desc "Specifies the account identity under which the application pool runs.
          Note: Starting in IIS 7.5 the default value is ApplicationPoolIdentity.
          (In IIS 7.0 the default value was NetworkService.)"
    newvalues(:ApplicationPoolIdentity, :LocalService, :LocalSystem,:NetworkService, :SpecificUser)
  end

  newproperty(:idle_timeout, :parent => PuppetX::PuppetLabs::IIS::Property::TimeFormat) do
    desc "Specifies how long (in minutes) a worker process should run idle if no new requests are received
          and the worker process is not processing requests. After the allocated time passes, the worker process
          should request that it be shut down by the WWW service."
  end

  newproperty(:idle_timeout_action) do
    desc "Specifies the action to perform when the idle timeout duration has been reached. Before IIS 8.5,
          a worker process that was idle for the duration of the idleTimeout attribute would be terminated.
          After IIS 8.5, you have the choice of terminating a worker process that reaches the idleTimeout limit,
          or suspending it by moving it from memory to disk. Suspending a process will likely take less time and
          consume less memory than terminating it.
          You can configure an idle timeout action of suspend with the fake request of application initialization
          (see applicationInitialization."
    newvalues(:Terminate, :Suspend)
  end

  newproperty(:load_user_profile, :boolean => true) do
    desc "Specifies whether IIS loads the user profile for the application pool identity. Setting this value to
          false causes IIS to revert to IIS 6.0 behavior. IIS 6.0 does not load the user profile for an
          application pool identity."
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:log_event_on_process_model, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "Specifies which action taken in the process gets logged to the Event Viewer. In IIS 8.0,
    the only action that applies is the idle timeout action, in which the process is terminated because
    it was idle for the idleTimeout period."
  end

  newproperty(:logon_type) do
    desc "Specifies the logon type for the process identity.
          (For additional information about logon types, see the LogonUser Function
          topic on Microsoft's MSDN Web site.)"
    newvalues(:LogonBatch, :LogonService)
  end

  newproperty(:manual_group_membership, :boolean => true) do
    desc "Specifies whether the IIS_IUSRS group Security Identifier (SID) is added to the worker process token. When false, IIS automatically uses an application pool identity as though it were a member of the built-in IIS_IUSRS group, which has access to necessary file and system resources. When true, an application pool identity must be explicitly added to all resources that a worker process requires at runtime."
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:max_processes, :parent => PuppetX::PuppetLabs::IIS::Property::PositiveInteger) do
    desc "Indicates the maximum number of worker processes that would be used for the application pool.
A value of '1' indicates a maximum of a single worker process for the application pool. This would be the setting on a server that does not have NUMA nodes.
A value of '2' or more indicates a Web garden that uses multiple worker processes for an application pool (if necessary).
A value of '0' specifies that IIS runs the same number of worker processes as there are Non-Uniform Memory Access (NUMA) nodes. IIS identifies the number of NUMA nodes that are available on the hardware and starts the same number of worker processes. For example, if you have four NUMA nodes, it will use a maximum of four worker processes for that application pool. In this example, setting maxProcesses to a value of '0' or '4' would have the same result."
    validate do |value|
      super value
      fail "#{self.name.to_s} should be less than or equal to 2147483647" unless value.to_i <= 2147483647
    end
  end

  newproperty(:pinging_enabled, :boolean => true) do
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:ping_interval, :parent => PuppetX::PuppetLabs::IIS::Property::TimeFormat) do
    desc "Specifies the time between health-monitoring pings that the WWW service sends to a worker process"
  end

  newproperty(:ping_response_time, :parent => PuppetX::PuppetLabs::IIS::Property::TimeFormat) do
    desc "Specifies the time that a worker process is given to respond to a health-monitoring ping.
          After the time limit is exceeded, the WWW service terminates the worker process."
  end

  newproperty(:set_profile_environment, :boolean => true) do
    desc "When setProfileEnvironment is set to True, WAS creates an environment block to pass to CreateProcessAsUser when creating a worker process. This ensures that the environment is set based on the user profile for the new process."
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:shutdown_time_limit, :parent => PuppetX::PuppetLabs::IIS::Property::TimeFormat) do
    desc "Specifies the time that the W3SVC service waits after it initiated a recycle. If the worker process does not shut down within the shutdownTimeLimit, it will be terminated by the W3SVC service."
  end

  newproperty(:startup_time_limit, :parent => PuppetX::PuppetLabs::IIS::Property::TimeFormat) do
    desc "Specifies the time that IIS waits for an application pool to start. If the application pool does not startup within the startupTimeLimit, the worker process is terminated and the rapid-fail protection count is incremented."
  end

  newproperty(:user_name, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "Specifies the identity under which the application pool runs when the identityType is `SpecificUser`"
  end

  newproperty(:password, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "Specifies the password associated with the userName attribute. This attribute is only necessary when the value of `identity_type` is `SpecificUser`.
          Note: To avoid storing unencrypted password strings in configuration files, this uses AppCmd.exe. This encrypts the password automatically before it is written to the XML configuration files. This provides better password security than storing unencrypted passwords."
  end

  newproperty(:orphan_action_exe, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
  end

  newproperty(:orphan_action_params, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
  end

  newproperty(:orphan_worker_process, :boolean => true) do
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:load_balancer_capabilities) do
    newvalues('HttpLevel', 'TcpLevel')
  end

  newproperty(:rapid_fail_protection, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
  end

  newproperty(:rapid_fail_protection_interval, :parent => PuppetX::PuppetLabs::IIS::Property::TimeFormat) do
  end

  newproperty(:rapid_fail_protection_max_crashes, :parent => PuppetX::PuppetLabs::IIS::Property::PositiveInteger) do
    validate do |value|
      super value
      fail "#{self.name.to_s} should be less than or equal to 2147483647" unless value.to_i <= 2147483647
    end
  end

  newproperty(:auto_shutdown_exe, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
  end

  newproperty(:auto_shutdown_params, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
  end

  newproperty(:disallow_overlapping_rotation, :boolean => true) do
    desc "Specifies whether the WWW Service should start another worker process to replace the existing worker process while that process is shutting down. The value of this property should be set to true if the worker process loads any application code that does not support multiple worker processes."
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:disallow_rotation_on_config_change, :boolean => true) do
    desc "Specifies whether the WWW Service should rotate worker processes in an application pool when the configuration has changed."
    newvalues(:true, :false)
       
    munge do |value|
      resource.munge_boolean(value)
    end
  end

  newproperty(:log_event_on_recycle, :parent => PuppetX::PuppetLabs::IIS::Property::String) do
    desc "Specifies that IIS should log an event when an application pool is recycled. The logEventOnRecycle property must have a bit set corresponding to the reason for the recycle if IIS is to log the event.
          The logEventOnRecycle attribute can have one or more of the following possible values. If you specify more than one value, separate them with a comma (,). The default flags for versions of IIS earlier than IIS 10 are Time, Memory, and PrivateMemory; for IIS 10 and later are Time, Requests, Schedule, Memory, IsapiUnhealthy, OnDemand, ConfigChange, and PrivateMemory;"
  end

  newproperty(:restart_memory_limit, :parent => PuppetX::PuppetLabs::IIS::Property::PositiveInteger) do
    desc "Specifies the amount of virtual memory (in kilobytes) that a worker process can use before the worker process is recycled. The maximum value supported for this property is 4,294,967 KB"
  end

  newproperty(:restart_private_memory_limit, :parent => PuppetX::PuppetLabs::IIS::Property::PositiveInteger) do
    desc "Specifies the amount of private memory (in kilobytes) that a worker process can use before the worker process recycles. The maximum value supported for this property is 4,294,967 KB"
  end

  newproperty(:restart_requests_limit, :parent => PuppetX::PuppetLabs::IIS::Property::PositiveInteger) do
    desc "Specifies that the worker process should be recycled after it processes a specific number of requests."
  end

  newproperty(:restart_time_limit, :parent => PuppetX::PuppetLabs::IIS::Property::TimeFormat) do
    desc "Specifies that the worker process should be recycled after a specified amount of time has elapsed."
  end

  newproperty(:restart_schedule, :parent => PuppetX::PuppetLabs::IIS::Property::TimeFormat) do
    desc "specifies the time intervals between restarts of worker processes in an application pool."
  end


  def munge_boolean(value)
    case value
      when true, "true", :true
        :true
      when false, "false", :false
        :false
      else
        fail("munge_boolean only takes booleans")
    end
  end
end
