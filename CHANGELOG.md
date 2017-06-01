## 2017-06-05 - Version 4.0.0

### Summary

This is the first supported release of the IIS module

### Features

- Added support for Windows Server 2008 R2 (IIS 7.5) ([MODULES-4484](https://tickets.puppetlabs.com/browse/MODULES-4484), [MODULES-4378](https://tickets.puppetlabs.com/browse/MODULES-4378))
- `iis_site` autorequires a `iis_application_pool` resource ([MODULES-4297](https://tickets.puppetlabs.com/browse/MODULES-4297))
- Added Types/Providers
  - `iis_application` ([MODULES-3050](https://tickets.puppetlabs.com/browse/MODULES-3050))
  - `iis_virtual_directory` ([MODULES-3053](https://tickets.puppetlabs.com/browse/MODULES-3053))
- Added MIGRATION.md for migrating the IIS module from voxpupuli to puppetlabs

### Bug Fixes

- Removed the usage of APPCMD
- Fixed minor typo in the iis_feature provider
- Fix error message for SSL settings on HTTP binding ([MODULES-4762](https://tickets.puppetlabs.com/browse/MODULES-4762))
- Update documentation for new types and providers ([MODULES-4752](https://tickets.puppetlabs.com/browse/MODULES-4752), [MODULES-4220](https://tickets.puppetlabs.com/browse/MODULES-4220), [MODULES-4564](https://tickets.puppetlabs.com/browse/MODULES-4564), [MODULES-4976](https://tickets.puppetlabs.com/browse/MODULES-4976))
- Fix testing the `iis_feature` provider ([MODULES-4818](https://tickets.puppetlabs.com/browse/MODULES-4818))


## 2017-03-16 - Version 0.1.0

### Summary

This is the initial, unsupported release with functionality to manage IIS application pools, sites and installation.

### Features

- Added `iis_version` fact
- Added Types/Providers
  - `iis_application_pool` ([MODULES-4185](https://tickets.puppetlabs.com/browse/MODULES-4185), [MODULES-4220](https://tickets.puppetlabs.com/browse/MODULES-4220))
  - `iis_site` ([MODULES-3049](https://tickets.puppetlabs.com/browse/MODULES-3049), [MODULES-3887](https://tickets.puppetlabs.com/browse/MODULES-3887))
  - `iis_feature` ([MODULES-4434](https://tickets.puppetlabs.com/browse/MODULES-4434))
