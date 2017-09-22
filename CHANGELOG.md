## 2017-09-26 - Version 4.1.1

### Summary

This is a minor release with bug fixes.

### Added

- Enabled iis_site preleoadenabled ([MODULES-5576](https://tickets.puppetlabs.com/browse/MODULES-5576))
- Added 'No Managed Code' value to managed_runtime_version in iis_site ([MODULES-5381](https://tickets.puppetlabs.com/browse/MODULES-5381))

### Fixed

- Allow valid characters in title and name for iis_site ([MODULES-5443](https://tickets.puppetlabs.com/browse/MODULES-5443))

## 2017-08-18 - Version 4.1.0

### Summary

This is a minor release, with bug fixes and documentation changes.

### Added

- Added ability to update physical path and application pool for sites ([MODULES-5125](https://tickets.puppetlabs.com/browse/MODULES-5125))
- Updated metadata to support Puppet 5 ([MODULES-5144](https://tickets.puppetlabs.com/browse/MODULES-5144))

### Fixed

- Removed redundant ordering in README examples
- Added testing of module on Puppet 5 ([MODULES-5187](https://tickets.puppetlabs.com/browse/MODULES-5187))
- Added more acceptance testing of Application Pool settings ([MODULES-5195](https://tickets.puppetlabs.com/browse/MODULES-5195))
- Added iis_virtual_directory to README ([MODULES-5433](https://tickets.puppetlabs.com/browse/MODULES-5433))
- Fixed various formatting issues in README ([MODULES-5433](https://tickets.puppetlabs.com/browse/MODULES-5433))
- Fixed certificate thumbprints to be case insensitive and handle nil values ([MODULES-5259](https://tickets.puppetlabs.com/browse/MODULES-5259))
- Fixed iis_application_pool settings not being idempotent  ([MODULES-5169](https://tickets.puppetlabs.com/browse/MODULES-5169))
- Fixed iis_site settings not being idempotent  ([MODULES-5429](https://tickets.puppetlabs.com/browse/MODULES-5429))


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
