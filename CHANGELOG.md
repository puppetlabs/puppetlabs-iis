## 2018-03-22 - Version 4.3.1

This is a minor release with bug fixes.

### Fixed

- iis_website causes state changes on each run when `ensure` property is set to `present`. ([MODULES-6673](https://tickets.puppetlabs.com/browse/MODULES-6673))
- iis_website has port conflict on create if only host name is different in binding information ([MODULES-6637](https://tickets.puppetlabs.com/browse/MODULES-6637))
- iis_site does not support `authenticationinfo` ([MODULES-5229](https://tickets.puppetlabs.com/browse/MODULES-5229))
## 2018-01-26 - Version 4.3.0

### Summary

This is a minor release with bug fixes, and one new property added to manage connection limits for IIS Sites.

### Added

- Setting site limits for [iis_site](https://github.com/puppetlabs/puppetlabs-iis#limits) ([MODULES-6144](https://tickets.puppetlabs.com/browse/MODULES-6144))

### Fixed

- iis_application resource cannot manage applications in nested site folders ([MODULES-6257](https://tickets.puppetlabs.com/browse/MODULES-6257))
- Resources require a second run when iis feature is installed ([MODULES-5465](https://tickets.puppetlabs.com/browse/MODULES-5465))
- iis_site binds to port 80 regardless of binding override on first run ([MODULES-6385](https://tickets.puppetlabs.com/browse/MODULES-6385))
- Puppet resource iis_virtual_directory doesn't fail with a meaningful error when sitename is omitted ([MODULES-6166](https://tickets.puppetlabs.com/browse/MODULES-6166))
- PowerShell manager code was updated to use named pipes to match the improvements in the [puppetlabs-powershell](https://github.com/puppetlabs/puppetlabs-powershell) module. ([MODULES-6283](https://tickets.puppetlabs.com/browse/MODULES-6283))

## 2017-12-01 - Version 4.2.1

### Summary

This is a minor release with bug fixes.

### Added

- Added support for user_name and password when using a UNC physicalpath with iis_virtual_directory ([MODULES-6195](https://tickets.puppetlabs.com/browse/MODULES-6195))

### Fixed

- IIS physicalpath regex doesn't match UNC paths ([MODULES-5264](https://tickets.puppetlabs.com/browse/MODULES-5264))
- IIS identity information is applied to application pool every agent run ([MODULES-5270](https://tickets.puppetlabs.com/browse/MODULES-5270))
- IIS virtual directory cant use UNC path ([MODULES-5642](https://tickets.puppetlabs.com/browse/MODULES-5642))
- IIS module remove warning already initialized constant ([MODULES-5954](https://tickets.puppetlabs.com/browse/MODULES-5954))
- IIS module cannot change application pool of existing iis_application ([MODULES-6020](https://tickets.puppetlabs.com/browse/MODULES-6020))
- IIS iis_virtual_directory calls update after destroy ([MODULES-6062](https://tickets.puppetlabs.com/browse/MODULES-6062))
- IIS iis_site applicationpool does not allow valid characters ([MODULES-6069](https://tickets.puppetlabs.com/browse/MODULES-6069))

## 2017-11-10 - Version 4.2.0

### Summary

This is a feature release, with IIS 10 and Server 2016 Core support.

### Added

- Added support for IIS 10 (Server 2016) ([MODULES-5801](https://tickets.puppetlabs.com/browse/MODULES-5801))
- Added support for Server 2016 Core ([MODULES-5803](https://tickets.puppetlabs.com/browse/MODULES-5803))
- Added a GitHub Pull Request template to help community submissions

## 2017-11-04 - Version 4.1.2

### Summary

This is a minor release with bug fixes.

### Fixed

- Loosen restriction on names for iis_site ([MODULES-5293](https://tickets.puppetlabs.com/browse/MODULES-5293))
- Loosen restriction on name for iis_application_pool ([MODULES-5626](https://tickets.puppetlabs.com/browse/MODULES-5626))
- Loosen restriction on iis_application applicationname parameter ([MODULES-5627](https://tickets.puppetlabs.com/browse/MODULES-5627))
- Fix iis_virtual_directory idempotency ([MODULES-5344](https://tickets.puppetlabs.com/browse/MODULES-5344))
- Add support for net.pipe protocol to iis_site ([MODULES-5521](https://tickets.puppetlabs.com/browse/MODULES-5521))

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
