# iis

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with IIS](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Facts](#facts)
    * [Types/Providers](#types/providers)
        * [iis_application](#iis_application)
        * [iis_application_pool](#iis_application_pool)
        * [iis_feature](#iis_feature)
        * [iis_site](#iis_site)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module adds a provider to manage IIS sites and application pools.

## Setup

### Beginning with puppetlabs-iis

This module can both manage and install IIS on your server. For example, a minimal IIS install can be accomplished by ensuring the `Web-WebServer` & `Web-Scripting-Tools` Windows Features are present.

Here is an example that installs IIS and creates a web site using the default application pool.

```puppet
$iis_features = ['Web-WebServer','Web-Scripting-Tools']

iis_feature { $iis_features:
  ensure => present,
} ->

iis_site { 'minimal':
  ensure          => 'started',
  physicalpath    => 'c:\\inetpub\\minimal',
  applicationpool => 'DefaultApplicationPool',
}
```

## Usage

This example will create and configure an IIS `web site` in the `Started` state with the physical path set, which makes use of an IIS `application pool` named `minimal_site_app_pool` in the `Started` state.

```puppet
iis_application_pool { 'minimal_site_app_pool':
  ensure                  => 'present',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
  state                   => 'Started'
} ->

iis_site { 'minimal':
  ensure          => 'started',
  physicalpath    => 'c:\\inetpub\\minimal',
  applicationpool => 'minimal_site_app_pool',
}
```

This complete example will create and configure an IIS Site called 'complete' in the `Started` state with the physical path set, which makes use of an IIS Application Pool named 'complete_site_app_pool' in the `Started` state. This example also uses HTTPS, sets the certificate information and creates a virtual directory called 'vdir' in the site.

```puppet
# Create Directory Structure
file { 'c:\\inetpub\\complete':
  ensure => 'directory'
} ->
file { 'c:\\inetpub\\complete_vdir':
  ensure => 'directory'
}

# This example makes use of the puppetlabs-acl module to set the permissions on the
# the web site directories
acl { 'c:\\inetpub\\complete':
  permissions                => [
    {'identity' => 'IISCompleteGroup', 'rights' => ['read', 'execute']},
  ],
  require => File['c:\\inetpub\\complete'],
}
acl { 'c:\\inetpub\\complete_vdir':
  permissions                => [
    {'identity' => 'IISCompleteGroup', 'rights' => ['read', 'execute']},
  ],
  require => File['c:\\inetpub\\complete_vdir'],
}

# IIS Configuration
iis_application_pool { 'complete_site_app_pool':
  ensure                  => 'present',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
  state                   => 'Started'
}

iis_site { 'complete':
  ensure          => 'started',
  physicalpath    => 'c:\\inetpub\\complete',
  applicationpool => 'complete_site_app_pool',
  enabledprotocols     => 'https',
  bindings             => [
    {
      'bindinginformation'   => '*:443:',
      'protocol'             => 'https',
      'certificatehash'      => '3598FAE5ADDB8BA32A061C5579829B359409856F',
      'certificatestorename' => 'MY',
      'sslflags'             => 1,
    },
  ],
  require => File['c:\\inetpub\\complete'],
}

iis_virtual_directory { 'vdir':
  ensure       => 'present',
  sitename     => 'complete',
  physicalpath => 'c:\\inetpub\\complete_vdir',
  require => File['c:\\inetpub\\complete_vdir'],
}
```

## Reference

### Facts

* `iis_version` - The version of the installed IIS. Empty string if not installed.

### Types/Providers

* [iis_application](#iis_application)
* [iis_application_pool](#iis_application_pool)
* [iis_feature](#iis_feature)
* [iis_site](#iis_site)

### iis_application

Allows creation of a new IIS application.

#### `ensure`

Must be either 'present' or 'absent'. Present will ensure the application pool is created.

#### `applicationname`

The name of the Application. The virtual path of an application is '/<applicationname>'.

#### `sitename`

The name of the site for this IIS Web Application.

#### `physicalpath`

The physical path to the IIS web application folder.  This path must be fully qualified.

#### `applicationpool`

The name of an application pool for this IIS Web Application.

#### `virtual_directory`

The Web Virtual Directory to convert to a Web Application on create.

#### `sslflags`

The SSL settings for the application.  Valid options are an array of 'Ssl, 'SslRequireCert', 'SslNegotiateCert', 'Ssl128'.

##### Example

Require the use of SSL

```puppet
iis_application { 'myapp':
  ensure       => 'present',
  sitename     => 'mysite',
  physicalpath => 'C:\\inetpub\\app',
  sslflags     => ['Ssl','SslRequireCert'],
}
```

#### `authenticationinfo`

Enable and disable IIS authentication schemas.

##### Example

Turn on basic authentication and disable anonymous.

```puppet
iis_application { 'myapp':
  ensure              => 'present',
  sitename           => 'mysite',
  physicalpath       => 'C:\\inetpub\\app',
  authenticationinfo => {
    'basic'     => true,
    'anonymous' => false,
  },
}
```

### iis_application_pool

Allows creation of a new IIS application pool.

#### `ensure`

Must be either `present` or `absent`. Present will ensure the application pool is created.

#### `name`

Name of the application pool.

#### `state`

The state of the application pool. Must be either `Started` or `Stopped`.

#### `auto_start`

When `true`, indicates to the World Wide Web Publishing Service (W3SVC) that the application pool should be automatically started when it is created or when IIS is started. Valid options `true` or `false`.

#### `clr_config_file`

Specifies the .NET configuration file for the application pool.

#### `enable32_bit_app_on_win64`

When `true`, enables a 32-bit application to run on a computer that runs a 64-bit version of Windows. Valid options `true` or `false`.

#### `enable_configuration_override`

When `true`, indicates that delegated settings in Web.config files will processed for applications within this application pool. When `false`, all settings in Web.config files will be ignored for this application pool. Valid options `true` or `false`.

#### `managed_pipeline_mode`

Specifies the request-processing mode that is used to process requests for managed content. Must be either 'Integrated' or 'Classic'.

#### `managed_runtime_loader`

Specifies the managed loader to use for pre-loading the the application pool.Note: This property was added in IIS 7.5. The default value is 'webengine4.dll'.

#### `managed_runtime_version`

Specifies the .NET Framework version that is used by the application pool.

#### `pass_anonymous_token`

When `true`, the Windows Process Activation Service (WAS) creates and passes a token for the built-in IUSR anonymous user account to the Anonymous authentication module. The Anonymous authentication module uses the token to impersonate the built-in account. When `false`, the token is not passed. Note: The IUSR anonymous user account replaces the IIS_MachineName anonymous account. The IUSR account can be used by IIS or other applications. It does not have any privileges assigned to it during setup. Valid options `true` or `false`.

#### `start_mode`

Specifies the startup type for the application pool. Valid options 'OnDemand' or 'AlwaysRunning'.

#### `queue_length`

Indicates to HTTP.sys how many requests to queue for an application pool before rejecting future requests. When the value set for this property is exceeded, IIS rejects subsequent requests with a 503 error. If the `load_balancer_capabilities` setting is 'TcpLevel', the connection is closed instead of rejecting requests with a 503. For more information about `load_balancer_capabilities`, see [Failure Settings for an Application Pool](https://www.iis.net/configreference/system.applicationhost/applicationPools/add/failure). Valid options 11 to 65535.

#### `cpu_action`

Configures the action that IIS takes when a worker process exceeds its configured CPU limit. Valid options 'NoAction', 'KillW3wp', 'Throttle' or 'ThrottleUnderLoad'.

#### `cpu_limit`

Configures the maximum percentage of CPU time (in 1/1000ths of one percent) that the worker processes in an application pool are allowed to consume over a period of time as indicated by the `cpu_reset_interval` property. If the limit set by the limit property is exceeded, an event is written to the event log and an optional set of events can be triggered. These optional events are determined by the `cpu_action` property.

#### `cpu_reset_interval`

Specifies the reset period (in minutes) for CPU monitoring and throttling limits on an application pool. When the number of minutes elapsed since the last process accounting reset equals the number specified by this property, IIS resets the CPU timers for both the logging and limit intervals.

Important: The `cpu_reset_interval` value must be greater than the time between logging operations, otherwise IIS will reset counters before logging has occurred, and process accounting will not occur.

Note: Because process accounting in IIS uses Windows job objects to monitor CPU times for the whole process, process accounting will only log and throttle applications that are isolated in a separate process from IIS.

#### `cpu_smp_affinitized`

Specifies whether a particular worker process assigned to an application pool should also be assigned to a given CPU. This property is used together with the `cpu_smp_processor_affinity_mask` and `cpu_smp_processor_affinity_mask2` properties. Valid options `true` or `false`.

#### `cpu_smp_processor_affinity_mask`

Specifies the hexadecimal processor mask for multi-processor computers, which indicates to which CPU the worker processes in an application pool should be bound. Before this property takes effect, the `cpu_smp_affinitized` property must be set to `true` for the application pool.

Note: On 64-bit computers, the cpu_smp_processor_affinity_mask property contains the low-order DWORD for the processor mask, and the `cpu_smp_processor_affinity_mask2` property contains the high-order DWORD for the processor mask. On 32-bit computers, the `cpu_smp_processor_affinity_mask2` property has no effect.

If you set the value to 1 (which corresponds to 00000000000000001 in binary), the worker processes in an application pool run on only the first processor. If you set the value to 2 (which corresponds to 0000000000000010 in binary), the worker processes run on only the second processor. If you set the value to 3 (which corresponds to 0000000000000011 in binary) the worker processes run on both the first and second processors.

Note: Do not set this property to 0. Doing so disables symmetric multiprocessing (SMP) affinity and creates an error condition. This means that processes running on one CPU will not remain affiliated with that CPU throughout their lifetime.

#### `cpu_smp_processor_affinity_mask2`

Specifies the high-order DWORD hexadecimal processor mask for 64-bit multi-processor computers, which indicates to which CPU the worker processes in an application pool should be bound. Before this property takes effect, the `cpu_smp_affinitized` property must be set to `true` for the application pool.

Note: On 64-bit computers, the `cpu_smp_processor_affinity_mask` property contains the low-order DWORD for the processor mask, and the `cpu_smp_processor_affinity_mask2` property contains the high-order DWORD for the processor mask. On 32-bit computers, the `cpu_smp_processor_affinity_mask2` property has no effect.

#### `identity_type`

Specifies the account identity under which the application pool runs. Note: Starting in IIS 7.5 the default value is 'ApplicationPoolIdentity'. (In IIS 7.0 the default value was 'NetworkService').  Valid options 'ApplicationPoolIdentity', 'LocalService', 'LocalSystem', 'NetworkService', or 'SpecificUser'.

#### `idle_timeout`

Specifies how long (in minutes) a worker process should run idle if no new requests are received and the worker process is not processing requests. After the allocated time passes, the worker process requests that it be shut down by the WWW service.

#### `idle_timeout_action`

Specifies the action to perform when the `idle_timeout` duration has been reached. Before IIS 8.5, a worker process that was idle for the duration of the `idle_timeout` property would be terminated. After IIS 8.5, you have the choice of terminating a worker process that reaches the `idle_timeout` limit, or suspending it by moving it from memory to disk. Suspending a process will likely take less time and consume less memory than terminating it. Valid options 'Terminate' or 'Suspend'.

#### `load_user_profile`

Specifies whether IIS loads the user profile for the application pool identity. Setting this value to `false` causes IIS to revert to IIS 6.0 behavior. IIS 6.0 does not load the user profile for an application pool identity. Valid options `true` or `false`.

#### `log_event_on_process_model`

Specifies which action taken in the process gets logged to the Event Viewer. In IIS 8.0, the only action that applies is the `idle_timeout_action`, in which the process is terminated because it was idle for the `idle_timeout` period.

#### `logon_type`

Specifies the logon type for the process identity. (For additional information about logon types, see the LogonUser Function topic on Microsoft's MSDN Web site). Valid options 'LogonBatch' or 'LogonService'.

#### `manual_group_membership`

Specifies whether the IIS_IUSRS group Security Identifier (SID) is added to the worker process token. When `false`, IIS automatically uses an application pool identity as though it were a member of the built-in IIS_IUSRS group, which has access to necessary file and system resources. When `true`, an application pool identity must be explicitly added to all resources that a worker process requires at runtime. Valid options `true` or `false`.

#### `max_processes`

Indicates the maximum number of worker processes that would be used for the application pool.

A value of 1 indicates a maximum of a single worker process for the application pool. This would be the setting on a server that does not have NUMA nodes.

A value of 2 or more indicates a Web garden that uses multiple worker processes for an application pool (if necessary).

A value of 0 specifies that IIS runs the same number of worker processes as there are Non-Uniform Memory Access (NUMA) nodes. IIS identifies the number of NUMA nodes that are available on the hardware and starts the same number of worker processes. For example, if you have four NUMA nodes, it will use a maximum of four worker processes for that application pool. In this example, setting `max_processes` to a value of 0 or 4 would have the same result.

#### `pinging_enabled`

Specifies whether pinging is enabled for the worker process. Valid options `true` or `false`.

#### `ping_interval`

Specifies the time between health-monitoring pings that the WWW service sends to a worker process.

#### `ping_response_time`

Specifies the time that a worker process is given to respond to a health-monitoring ping.  After the time limit is exceeded, the WWW service terminates the worker process.

#### `set_profile_environment`

When set to `true`, WAS creates an environment block to pass to CreateProcessAsUser when creating a worker process. This ensures that the environment is set based on the user profile for the new process. Valid options `true` or `false`.

#### `shutdown_time_limit`

Specifies the time that the W3SVC service waits after it initiated a recycle. If the worker process does not shut down within the `shutdown_time_limit`, it will be terminated by the W3SVC service.

#### `startup_time_limit`

Specifies the time that IIS waits for an application pool to start. If the application pool does not startup within the `startup_time_limit`, the worker process is terminated and the rapid-fail protection count is incremented.

#### `user_name`

Specifies the identity under which the application pool runs when the `identity_type` is 'SpecificUser'.

#### `password`

Specifies the password associated with the `user_name` property. This property is only necessary when the value of `identity_type` is 'SpecificUser'.

Note: To avoid storing unencrypted password strings in configuration files, this uses AppCmd.exe. This encrypts the password automatically before it is written to the XML configuration files. This provides better password security than storing unencrypted passwords.

#### `orphan_action_exe`

Specifies an executable to run when the WWW service orphans a worker process (if the `orphan_worker_process` is set to `true`). You can use the `orphan_action_params` property to send parameters to the executable.

#### `orphan_action_params`

Indicates command-line parameters for the executable named by the `orphan_action_exe` property. To specify the process ID of the orphaned process use `%1%`.

#### `orphan_worker_process`

Specifies whether to assign a worker process to an orphan state instead of terminating it when an application pool fails. Valid options `true` or `false`.

#### `load_balancer_capabilities` do

Specifies behavior when a worker process cannot be started, such as when the request queue is full or an application pool is in rapid-fail protection. Valid options 'HttpLevel' or 'TcpLevel'.

#### rapid_fail_protection

Setting to `true` instructs the WWW service to remove from service all applications that are in an application pool when:

* The number of worker process crashes has reached the maximum specified in the `rapid_fail_protection_max_crashes` property.

* The crashes occur within the number of minutes specified in the `rapid_fail_protection_interval` property.

Valid options `true` or `false`.

#### `rapid_fail_protection_interval`

Specifies the number of minutes before the failure count for a process is reset.

#### `rapid_fail_protection_max_crashes`

Specifies the maximum number of failures allowed within the number of minutes specified by the `rapid_fail_protection_interval` property.

#### `auto_shutdown_exe`

Specifies an executable to run when the WWW service shuts down an application pool. You can use the `auto_shutdown_params` property to send parameters to the executable.

#### `auto_shutdown_params`

Specifies command-line parameters for the executable that is specified in the `auto_shutdown_exe` property.

#### `disallow_overlapping_rotation`

Specifies whether the WWW Service should start another worker process to replace the existing worker process while that process is shutting down. The value of this property should be set to `true` if the worker process loads any application code that does not support multiple worker processes. Valid options `true` or `false`.

#### `disallow_rotation_on_config_change`

Specifies whether the WWW Service should rotate worker processes in an application pool when the configuration has changed. Valid options `true` or `false`.

#### `log_event_on_recycle`

Specifies that IIS should log an event when an application pool is recycled. The `log_event_on_recycle` property must have a bit set corresponding to the reason for the recycle if IIS is to log the event. The `log_event_on_recycle` property can have one or more of the following possible values: 'ConfigChange', 'IsapiUnhealthy', 'Memory', 'OnDemand', 'PrivateMemory', 'Requests', 'Schedule' and 'Time'.

If you specify more than one value, separate them with a comma (,). The default flags for versions of IIS earlier than IIS 10 are 'Time', 'Memory', and 'PrivateMemory'; for IIS 10 and later are all values.

#### `restart_memory_limit`

Specifies the amount of virtual memory (in kilobytes) that a worker process can use before the worker process is recycled. The maximum value supported for this property is 4,294,967 KB.

#### `restart_private_memory_limit`

Specifies the amount of private memory (in kilobytes) that a worker process can use before the worker process recycles. The maximum value supported for this property is 4,294,967 KB.

#### `restart_requests_limit`

Specifies that the worker process should be recycled after it processes a specific number of requests.

#### `restart_time_limit`

Specifies that the worker process should be recycled after a specified amount of time has elapsed.

#### `restart_schedule`

Specifies the time intervals between restarts of worker processes in an application pool.


### iis_feature

##### `ensure`

Specifies whether an IIS feature should be present or absent.

##### `name`

The name of the IIS feature to install.

##### `include_all_subfeatures`

Indicates whether to install all sub features of a parent IIS feature. For instance, ASP.NET as well as the IIS Web Server.

##### `restart`

Indicates whether to allow a restart if the IIS feature installationrequests one.

##### `include_management_tools`

Indicates whether to automatically install all managment tools for a given IIS feature.

##### `source`

Optionally include a source path for the installation media for an IIS feature.


### iis_site

Allows creation of a new IIS website and configuration of various parameters.

#### Properties/Parameters

##### `ensure`

Specifies whether a site should be present or absent.
If present is specified, the site will be created but left in the default stopped state.
If started is specified, then the site will be created as well as started.
If stopped is specified, then the site will be created and kept stopped.

##### `name`

The Name of the IIS site. Used for uniqueness. Will set the target to this value if target is unset.

##### `physicalpath`

The physical path to the IIS web site folder.

##### `applicationpool`

The name of an application pool for this IIS Web Site.

##### `enabledprotocols`

The protocols enabled for this site. If https is specified, http is implied. If no value is provided, then this setting is disabled.

##### `bindings`

Specifies one or more bindings (The protocol, address, port, and ssl certificate) for a web site.

###### Examples

Use the default HTTP port

```puppet
iis_site { 'mysite':
  ensure               => 'started',
  applicationpool      => 'DefaultAppPool',
  enabledprotocols     => 'https',
  bindings             => [
    {
      'bindinginformation'   => '*:80:',
      'protocol'             => 'http',
    },
  ],
}
```

Use the default HTTPS port

```puppet
iis_site { 'mysite':
  ensure               => 'started',
  applicationpool      => 'DefaultAppPool',
  enabledprotocols     => 'https',
  bindings             => [
    {
      'bindinginformation'   => '*:443:',
      'protocol'             => 'https',
      'certificatehash'      => '3598FAE5ADDB8BA32A061C5579829B359409856F',
      'certificatestorename' => 'MY',
      'sslflags'             => 1,
    },
  ],
}
```

Multiple bindings, one for HTTP and another for HTTPS on non-default port

```puppet
iis_site { 'mysite':
  ensure               => 'started',
  applicationpool      => 'DefaultAppPool',
  enabledprotocols     => 'https',
  bindings             => [
    {
      'bindinginformation'   => '*:80:insecure.website.com',
      'protocol'             => 'http',
    },
    {
      'bindinginformation'   => '*:8443:',
      'protocol'             => 'https',
      'certificatehash'      => '3598FAE5ADDB8BA32A061C5579829B359409856F',
      'certificatestorename' => 'MY',
      'sslflags'             => 1,
    },
  ],
}
```

Each binding is a hash with the following keys:

###### `bindinginformation`

The `bindinginformation` value should be in the form of the IPv4/IPv6 address or wildcard *, then the port, then the optional hostname separated by colons:  `(ip|\*):[1-65535]:(hostname)`.

###### `certificatehash`

**Only valid with a protocol of https**

Specifies the thumbprint, also known as the certificatehash, of the certificate used by the IIS site. You can retrieve the thumbprint for a certificate using PowerShell, for example:

```powershell
PS> Get-ChildItem -Path Cert:\LocalMachine\My

   PSParentPath: Microsoft.PowerShell.Security\Certificate::LocalMachine\My

Thumbprint                                Subject
----------                                -------
D4765AA1CE1F25EC29677F87C95D818CE734C2E5  CN=www.webserver.local
```

###### `certificatestorename`

**Only valid with a protocol of https**

Specifies the certificate store to search for the relevant `certificatehash`.  Typically this is `MY` which is the Personal certificate store for the Local Machine.  You can retrieve the list of stores using PowerShell:

```powershell
PS> Get-ChildItem -Path Cert:\LocalMachine

Name : TrustedPublisher

Name : ClientAuthIssuer

Name : My

...
```

###### `protocol`

A value of `http` indicates a binding that uses the HTTP protocol. A value of `https` indicates a binding that uses HTTP over SSL.

###### `sslflags`

**Only valid with a protocol of https**

The `sslflags` parameter accepts integer values from 0 to 3.

* A value of 0 specifies that the secure connection be made using an IP/Port combination. Only one certificate can be bound to a combination of IP address and the port.

* A value of 1 specifies that the secure connection be made using the port number and the host name obtained by using Server Name Indication (SNI).

* A value of 2 specifies that the secure connection be made using the centralized SSL certificate store without requiring a Server Name Indicator.

* A value of 3 specifies that the secure connection be made using the centralized SSL certificate store while requiring Server Name Indicator.

##### `serviceautostart`

Enables autostart on the specified website.

##### `serviceautostartprovidername`

Specifies the provider used for service auto start. Used with :serviceautostartprovidertype. The `<serviceAutoStartProviders>` element specifies a collection of managed assemblies that Windows Process Activation Service (WAS) will load automatically when the startMode property of an application pool is set to AlwaysRunning. This collection allows developers to specify assemblies that perform initialization tasks before any HTTP requests are serviced.

###### Example

```puppet
iis_site { 'mysite'
  ...
  serviceautostartprovidername => "MyAutostartProvider",
  serviceautostartprovidertype => "MyAutostartProvider, MyAutostartProvider, version=1.0.0.0, Culture=neutral, PublicKeyToken=426f62526f636b73"
}
```

##### `serviceautostartprovidertype`

Specifies the application type for the provider used for service auto start. Used with :serviceautostartprovider.

###### Example

```puppet
iis_site { 'mysite'
  ...
  serviceautostartprovidername => "MyAutostartProvider",
  serviceautostartprovidertype => "MyAutostartProvider, MyAutostartProvider, version=1.0.0.0, Culture=neutral, PublicKeyToken=426f62526f636b73"
}
```

##### `preloadenabled`

Enables loading website automatically without a client request first.

##### `defaultpage`

Specifies the default page of the site.

##### `logformat`

Specifies the format for the log file. When set to WSC, it can be used in conjunction with :logflags.

##### `logpath`

Specifies the physical path to place the log file.

##### `logperiod`

Specifies how often the log file should rollover.

##### `logtruncatesize`

Specifies how large the log file should be before truncating it. The value must be in bytes. The value can be any size between '1048576 (1MB)' and '4294967295 (4GB)'.

##### `loglocaltimerollover`

Use the system's local time to determine for the log file name as well as when the log file is rolled over.

##### `logflags`

Specifies what W3C fields are logged in the IIS log file. This is only valid when :logformat is set to W3C.


## Limitations

### Compatibility

#### OS Compatibility

This module is compatible only with `Windows Server 2008R2`, `Windows Server 2012`, `Windows Server 2012R2` & `Windows Server 2016`.

#### IIS Compatibility

This module only supports `IIS 7.5`, `IIS 8` or `IIS 8.5`.

#### PowerShell Compatibility

This module requires PowerShell v2 or greater. Works best with PowerShell v3 or above.

### Known Issues

N/A

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

Check out our the complete [module contribution guide](https://docs.puppetlabs.com/forge/contributing.html) or [CONTRIBUTING.md](CONTRIBUTING.md).
