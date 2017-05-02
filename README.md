# iis

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with IIS](#setup)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Facts](#facts)
    * [Types/Providers](#types/providers)
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

## Reference

### Facts

* `iis_version` - The version of the installed IIS. Empty string if not installed.

### Types/Providers

* [iis_application_pool](#iis_application_pool)
* [iis_feature](#iis_feature)
* [iis_site](#iis_site)

Here, include a complete list of your module's classes, types, providers, facts, along with the parameters for each. Users refer to this section (thus the name "Reference") to find specific details; most users don't read it per se.

### iis_application_pool

Allows creation of a new IIS application pool

#### `ensure`

Must be either `present` or `absent`. Present will ensure the application pool is created.

#### `name`

Name of the application pool.

#### `state`

The state of the ApplicationPool. Must be either `Started` or `Stopped`

#### `managed_pipeline_mode`

The managedpipelinemode of the ApplicationPool. Must be either `Integrated` or `Classic`

#### `managed_runtime_version`

The managedruntimeversion of the ApplicationPool.


### iis_feature

##### `ensure`

Specifies whether an IIS feature should be present or absent

##### `name`

The name of the IIS feature to install

##### `include_all_subfeatures`

Indicates whether to install all sub features of a parent IIS feature. For instance, ASP.NET as well as the IIS Web Server

##### `restart`

Indicates whether to allow a restart if the IIS feature installationrequests one

##### `include_management_tools`

Indicates whether to automatically install all managment tools for a given IIS feature

##### `source`

Optionally include a source path for the installation media for an IIS feature


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

The physical path to the IIS web site folder

##### `applicationpool`

The name of an ApplicationPool for this IIS Web Site

##### `enabledprotocols`

The protocols enabled for this site. If https is specified, http is implied. If no value is provided, then this setting is disabled

##### `bindings`

Specifies one or more bindings (The protocol, address, port, and ssl certificate) for a web site

###### Examples:

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
      'protocol'             => 'https',
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
      'protocol'             => 'https',
      'sslflags'             => 1,
    },
  ],
}
```

Each binding is a hash with the following keys:

###### `bindinginformation`

The `bindinginformation` value should be in the form of the IPv4/IPv6 address or wildcard *, then the port, then the optional hostname separated by colons:  `(ip|\*):[1-65535]:(hostname)`

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

A value of `http` indicates a binding that uses the HTTP protocol. A value of `https` indicates a binding that uses HTTP over SSL

###### `sslflags`

**Only valid with a protocol of https**

The `sslflags` parameter accepts integer values from 0 to 3.

* A value of 0 specifies that the secure connection be made using an IP/Port combination. Only one certificate can be bound to a combination of IP address and the port.

* A value of 1 specifies that the secure connection be made using the port number and the host name obtained by using Server Name Indication (SNI).

* A value of 2 specifies that the secure connection be made using the centralized SSL certificate store without requiring a Server Name Indicator.

* A value of 3 specifies that the secure connection be made using the centralized SSL certificate store while requiring Server Name Indicator.

##### `serviceautostart`

Enables autostart on the specified website

##### `serviceautostartprovidername`

Specifies the provider used for service auto start. Used with :serviceautostartprovidertype.
The <serviceAutoStartProviders> element specifies a collection of managed assemblies that Windows Process Activation Service (WAS) will load automatically when the startMode attribute of an application pool is set to AlwaysRunning. This collection allows developers to specify assemblies that perform initialization tasks before any HTTP requests are serviced.

###### Example:

```puppet
iis_site { 'mysite'
  ...
  serviceautostartprovidername => "MyAutostartProvider",
  serviceautostartprovidertype => "MyAutostartProvider, MyAutostartProvider, version=1.0.0.0, Culture=neutral, PublicKeyToken=426f62526f636b73"
}
```

##### `serviceautostartprovidertype`

Specifies the application type for the provider used for service auto start. Used with :serviceautostartprovider

###### Example:

```puppet
iis_site { 'mysite'
  ...
  serviceautostartprovidername => "MyAutostartProvider",
  serviceautostartprovidertype => "MyAutostartProvider, MyAutostartProvider, version=1.0.0.0, Culture=neutral, PublicKeyToken=426f62526f636b73"
}
```

##### `preloadenabled`

Enables loading website automatically without a client request first

##### `defaultpage`

Specifies the default page of the site

##### `logformat`

Specifies the format for the log file. When set to WSC, it can be used in conjunction with :logflags

##### `logpath`

Specifies the physical path to place the log file

##### `logperiod`

Specifies how often the log file should rollover

##### `logtruncatesize`

Specifies how large the log file should be before truncating it. The value must be in bytes. The value can be any size between '1048576 (1MB)' and '4294967295 (4GB)'.

##### `loglocaltimerollover`

Use the system's local time to determine for the log file name as well as when the log file is rolled over

##### `logflags`

Specifies what W3C fields are logged in the IIS log file. This is only valid when :logformat is set to W3C.


## Limitations

### Compatibility

#### OS Compatibility
This module is compatible only with `Windows Server 2008R2`, `Windows Server 2012`, `Windows Server 2012R2` & `Windows Server 2016`. 

#### IIS Compatibility
This module only supports `IIS 7.5`, `IIS 8` or `IIS 8.5`.

#### Powershell Compatibility
This module requires Powershell v2 or greater. Works best with PowerShell v3 or above.

### Known Issues

N/A

## Development

Puppet Labs modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

Check out our the complete [module contribution guide](https://docs.puppetlabs.com/forge/contributing.html) or [CONTRIBUTING.md](CONTRIBUTING.md).
