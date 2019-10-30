# iis

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
   * [Beginning with puppetlabs-iis](#beginning-with-puppetlabs-iis)
4. [Usage](#usage)
5. [Reference](#reference)
6. [Limitations](#limitations)
7. [Development](#development)

## Description

This module adds a provider to manage IIS sites and application pools.

## Setup

### Beginning with puppetlabs-iis

This module can both manage and install IIS on your server. For example, a minimal IIS install can be accomplished by ensuring the `Web-WebServer` and `Web-Scripting-Tools` Windows Features are present.

Here is an example that installs IIS and creates a web site using the default application pool.

```puppet
$iis_features = ['Web-WebServer','Web-Scripting-Tools']

iis_feature { $iis_features:
  ensure => 'present',
}

# Delete the default website to prevent a port binding conflict.
iis_site {'Default Web Site':
  ensure  => absent,
  require => Iis_feature['Web-WebServer'],
}

iis_site { 'minimal':
  ensure          => 'started',
  physicalpath    => 'c:\\inetpub\\minimal',
  applicationpool => 'DefaultAppPool',
  require         => [
    File['minimal'],
    Iis_site['Default Web Site']
  ],
}

file { 'minimal':
  ensure => 'directory',
  path   => 'c:\\inetpub\\minimal',
}
```

## Usage

This minimal example will create a web site named 'complete' using an application pool named 'minimal_site_app_pool'.

```puppet
iis_application_pool { 'minimal_site_app_pool':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
} ->

iis_site { 'minimal':
  ensure          => 'started',
  physicalpath    => 'c:\\inetpub\\minimal',
  applicationpool => 'minimal_site_app_pool',
  require         => File['minimal'],
}

file { 'minimal':
  ensure => 'directory',
  path   => 'c:\\inetpub\\minimal',
}
```

This complete example will create a web site named 'complete' using an application pool named 'complete_site_app_pool', with a virtual directory named 'vdir'. This example uses the `puppetlabs-acl module` to set permissions on directories.

```puppet
# Create Directories

file { 'c:\\inetpub\\complete':
  ensure => 'directory'
}

file { 'c:\\inetpub\\complete_vdir':
  ensure => 'directory'
}

# Set Permissions

acl { 'c:\\inetpub\\complete':
  permissions => [
    {'identity' => 'IISCompleteGroup', 'rights' => ['read', 'execute']},
  ],
}

acl { 'c:\\inetpub\\complete_vdir':
  permissions => [
    {'identity' => 'IISCompleteGroup', 'rights' => ['read', 'execute']},
  ],
}

# Configure IIS

iis_application_pool { 'complete_site_app_pool':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
}

#Application Pool No Managed Code .Net CLR Version set up
iis_application_pool {'test_app_pool':
    ensure                    => 'present',
    enable32_bit_app_on_win64 => true,
    managed_runtime_version   => '',
    managed_pipeline_mode     => 'Classic',
    start_mode                => 'AlwaysRunning'
  }

iis_site { 'complete':
  ensure           => 'started',
  physicalpath     => 'c:\\inetpub\\complete',
  applicationpool  => 'complete_site_app_pool',
  enabledprotocols => 'https',
  bindings         => [
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
  require      => File['c:\\inetpub\\complete_vdir'],
}
```

## Reference

For information on the classes and types, see the [REFERENCE.md](https://github.com/puppetlabs/puppetlabs-iis/blob/master/REFERENCE.md).

## Limitations

### Compatibility

#### OS Compatibility

This module is compatible only with `Windows Server 2008R2`, `Windows Server 2012`, `Windows Server 2012R2`, `Windows Server 2016`,`Windows Server 2016 Core` and `Windows Server 2019`.

#### IIS Compatibility

This module only supports `IIS 7.5`, `IIS 8`, `IIS 8.5` or `IIS 10.0`.

#### PowerShell Compatibility

This module requires PowerShell v2 or greater. Works best with PowerShell v3 or above.

### Known Issues

N/A

## Development

If you would like to contribute to this module, please follow the rules in the [CONTRIBUTING.md](https://github.com/puppetlabs/puppetlabs-iis/blob/master/CONTRIBUTING.md). For more information, see our [module contribution guide.](https://puppet.com/docs/puppet/latest/contributing.html)
