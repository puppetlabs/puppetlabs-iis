## [v6.0.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v6.0.0) (2019-10-30)

**The 6.0.0 release only contains maintenance work and should have been 5.0.1.**

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v5.0.0...v6.0.0)

## v5.0.0

### Changed

- Increase the named pipe timeout to 180 seconds to prevent runs from failing waiting for a pipe to open ([MODULES-9087](https://tickets.puppetlabs.com/browse/MODULES-9087)).
- Update minimum Puppet version to 5.5.10 ([MODULES-9349](https://tickets.puppetlabs.com/browse/MODULES-9349))

### Fixed

- Ensure setting `iis_application_pool` state is idempotent ([MODULES-7700](https://tickets.puppetlabs.com/browse/MODULES-7700)).
- Ensure setting `:managed_runtime_version` to `''` results in `iis_app_pool` being set to `No Managed Code` idempotently ([MODULES-7820](https://tickets.puppetlabs.com/browse/MODULES-7820)).
- Ensure ability to specify timespans which include days, such as `1.05:00:00` ([MODULES-8381]. (https://tickets.puppetlabs.com/browse/MODULES-8381)). Thanks, Trey Dockendorf ([@treydock](https://github.com/treydock))!
- Ensure iis_feature source property is used when provided in a manifest ([MODULES-8254](https://tickets.puppetlabs.com/browse/MODULES-8254))

## [4.5.1] - 2019-03-02

### Added

- Windows Server 2019 added to supported OS list ([FM-7693](https://tickets.puppetlabs.com/browse/FM-7693))

### Fixed

- Ensure removal of virtual directories is idempotent ([MODULES-6080](https://tickets.puppetlabs.com/browse/MODULES-6080)).
- Case sensitive path comparisons ([MODULES-8346](https://tickets.puppetlabs.com/browse/MODULES-8346))
- Virtual directories did not correct config drift ([MODULES-6061](https://tickets.puppetlabs.com/browse/MODULES-6061))

## [4.5.0] - 2018-10-23

### Fixed

- `iis_application` cannot manage two applications with the same name under different web sites ([MODULES-5493](https://tickets.puppetlabs.com/browse/MODULES-5493))
- `applicationname` parameter cannot start with '/' character. Fixed as a by product of [MODULES-5493](https://tickets.puppetlabs.com/brows/MODULES-5493).
- Removing an IIS feature using the module results in an error. ([MODULES-7174](https://tickets.puppetlabs.com/browse/MODULES-7174)). Thanks Brian Fekete ([@bFekete](https://github.com/bfekete)).

### Changed

- The direction of slashes used in the title of an `iis_application` resource no longer matters. This is true both for the slash that separates the `sitename` portion of the title from the `applicationname` name, and also for the path separator used if the application path is nested deeply in folders under the web site.

## [4.4.0] - 2018-09-05

### Added

- Added additional valid binding protocols for `iis_application`. ([MODULES-6947](https://tickets.puppetlabs.com/browse/MODULES-6947)). Thanks Pedro Cunha ([@Pedro-Cunha](https://github.com/Pedro-Cunha)).

### Fixed

- Fixed password escaping for the `iis_application_pool` and `iis_virtual_directory` types. ([MODULES-6870](https://tickets.puppetlabs.com/browse/MODULES-6870))

## [4.3.2] - 2018-06-13

### Fixed

- `iis_website`, with a port binding of 443, does not start. ([MODULES-7173](https://tickets.puppetlabs.com/browse/MODULES-7173))
- Custom PowerShell host unreliable on some versions of Windows 2008 ([MODULES-6928](https://tickets.puppetlabs.com/browse/MODULES-6928))

## [4.3.1] - 2018-03-22

### Fixed

- `iis_website` causes state changes on each run when `ensure` property is set to `present`. ([MODULES-6673](https://tickets.puppetlabs.com/browse/MODULES-6673))
- `iis_website` has port conflict on create if only host name is different in binding information ([MODULES-6637](https://tickets.puppetlabs.com/browse/MODULES-6637))
- `iis_site` does not support `authenticationinfo` ([MODULES-5229](https://tickets.puppetlabs.com/browse/MODULES-5229))

## [4.3.0] - 2018-01-26

### Added

- Setting site limits for [iis_site](https://github.com/puppetlabs/puppetlabs-iis#limits) ([MODULES-6144](https://tickets.puppetlabs.com/browse/MODULES-6144))

### Fixed

- `iis_application` resource cannot manage applications in nested site folders ([MODULES-6257](https://tickets.puppetlabs.com/browse/MODULES-6257))
- Resources require a second run when iis feature is installed ([MODULES-5465](https://tickets.puppetlabs.com/browse/MODULES-5465))
- `iis_site` binds to port 80 regardless of binding override on first run ([MODULES-6385](https://tickets.puppetlabs.com/browse/MODULES-6385))
- Puppet resource `iis_virtual_directory` doesn't fail with a meaningful error when sitename is omitted ([MODULES-6166](https://tickets.puppetlabs.com/browse/MODULES-6166))
- PowerShell manager code was updated to use named pipes to match the improvements in the [puppetlabs-powershell](https://github.com/puppetlabs/puppetlabs-powershell) module. ([MODULES-6283](https://tickets.puppetlabs.com/browse/MODULES-6283))

## [4.2.1] - 2017-12-01

### Added

- Added support for user_name and password when using a UNC physicalpath with `iis_virtual_directory` ([MODULES-6195](https://tickets.puppetlabs.com/browse/MODULES-6195))

### Fixed

- IIS physicalpath regex doesn't match UNC paths ([MODULES-5264](https://tickets.puppetlabs.com/browse/MODULES-5264))
- IIS identity information is applied to application pool every agent run ([MODULES-5270](https://tickets.puppetlabs.com/browse/MODULES-5270))
- IIS virtual directory can't use UNC path ([MODULES-5642](https://tickets.puppetlabs.com/browse/MODULES-5642))
- IIS module remove warning already initialized constant ([MODULES-5954](https://tickets.puppetlabs.com/browse/MODULES-5954))
- IIS module cannot change application pool of existing `iis_application` ([MODULES-6020](https://tickets.puppetlabs.com/browse/MODULES-6020))
- IIS `iis_virtual_directory` calls update after destroy ([MODULES-6062](https://tickets.puppetlabs.com/browse/MODULES-6062))
- IIS `iis_site` applicationpool does not allow valid characters ([MODULES-6069](https://tickets.puppetlabs.com/browse/MODULES-6069))

## [4.2.0] - 2017-11-10

### Added

- Added support for IIS 10 (Server 2016) ([MODULES-5801](https://tickets.puppetlabs.com/browse/MODULES-5801))
- Added support for Server 2016 Core ([MODULES-5803](https://tickets.puppetlabs.com/browse/MODULES-5803))
- Added a GitHub Pull Request template to help community submissions

## [4.1.2] - 2017-11-04

### Fixed

- Loosen restriction on names for `iis_site` ([MODULES-5293](https://tickets.puppetlabs.com/browse/MODULES-5293))
- Loosen restriction on name for `iis_application_pool` ([MODULES-5626](https://tickets.puppetlabs.com/browse/MODULES-5626))
- Loosen restriction on `iis_application` applicationname parameter ([MODULES-5627](https://tickets.puppetlabs.com/browse/MODULES-5627))
- Fix `iis_virtual_directory` idempotency ([MODULES-5344](https://tickets.puppetlabs.com/browse/MODULES-5344))
- Add support for net.pipe protocol to `iis_site` ([MODULES-5521](https://tickets.puppetlabs.com/browse/MODULES-5521))

## [4.1.1] - 2017-09-26

### Added

- Enabled `iis_site` preleoadenabled ([MODULES-5576](https://tickets.puppetlabs.com/browse/MODULES-5576))
- Added 'No Managed Code' value to managed_runtime_version in `iis_site` ([MODULES-5381](https://tickets.puppetlabs.com/browse/MODULES-5381))

### Fixed

- Allow valid characters in title and name for `iis_site` ([MODULES-5443](https://tickets.puppetlabs.com/browse/MODULES-5443))

## [4.1.0] - 2017-08-18

### Added

- Added ability to update physical path and application pool for sites ([MODULES-5125](https://tickets.puppetlabs.com/browse/MODULES-5125))
- Added testing of module on Puppet 5 ([MODULES-5187](https://tickets.puppetlabs.com/browse/MODULES-5187))
- Added more acceptance testing of Application Pool settings ([MODULES-5195](https://tickets.puppetlabs.com/browse/MODULES-5195))
- Added `iis_virtual_directory` to README ([MODULES-5433](https://tickets.puppetlabs.com/browse/MODULES-5433))
- Updated metadata to add support Puppet 5 ([MODULES-5144](https://tickets.puppetlabs.com/browse/MODULES-5144))

### Fixed

- Removed redundant ordering in README examples
- Fixed various formatting issues in README ([MODULES-5433](https://tickets.puppetlabs.com/browse/MODULES-5433))
- Fixed certificate thumbprints to be case insensitive and handle nil values ([MODULES-5259](https://tickets.puppetlabs.com/browse/MODULES-5259))
- Fixed `iis_application_pool` settings not being idempotent  ([MODULES-5169](https://tickets.puppetlabs.com/browse/MODULES-5169))
- Fixed `iis_site` settings not being idempotent  ([MODULES-5429](https://tickets.puppetlabs.com/browse/MODULES-5429))


## [4.0.0] - 2017-06-05

### Added

- Added support for Windows Server 2008 R2 (IIS 7.5) ([MODULES-4484](https://tickets.puppetlabs.com/browse/MODULES-4484), [MODULES-4378](https://tickets.puppetlabs.com/browse/MODULES-4378))
- `iis_site` autorequires a `iis_application_pool` resource ([MODULES-4297](https://tickets.puppetlabs.com/browse/MODULES-4297))
- Added Types/Providers
  - `iis_application` ([MODULES-3050](https://tickets.puppetlabs.com/browse/MODULES-3050))
  - `iis_virtual_directory` ([MODULES-3053](https://tickets.puppetlabs.com/browse/MODULES-3053))
- Added MIGRATION.md for migrating the IIS module from voxpupuli to puppetlabs

### Fixed

- Fixed minor typo in the `iis_feature` provider
- Fix error message for SSL settings on HTTP binding ([MODULES-4762](https://tickets.puppetlabs.com/browse/MODULES-4762))
- Update documentation for new types and providers ([MODULES-4752](https://tickets.puppetlabs.com/browse/MODULES-4752), [MODULES-4220](https://tickets.puppetlabs.com/browse/MODULES-4220), [MODULES-4564](https://tickets.puppetlabs.com/browse/MODULES-4564), [MODULES-4976](https://tickets.puppetlabs.com/browse/MODULES-4976))
- Fix testing the `iis_feature` provider ([MODULES-4818](https://tickets.puppetlabs.com/browse/MODULES-4818))

### Removed

- Removed the usage of APPCMD

## 0.1.0 - 2017-03-16

### Added

- Added `iis_version` fact
- Added Types/Providers
  - `iis_application_pool` ([MODULES-4185](https://tickets.puppetlabs.com/browse/MODULES-4185), [MODULES-4220](https://tickets.puppetlabs.com/browse/MODULES-4220))
  - `iis_site` ([MODULES-3049](https://tickets.puppetlabs.com/browse/MODULES-3049), [MODULES-3887](https://tickets.puppetlabs.com/browse/MODULES-3887))
  - `iis_feature` ([MODULES-4434](https://tickets.puppetlabs.com/browse/MODULES-4434))

[Unreleased]: https://github.com/puppetlabs/puppetlabs-iis/compare/4.5.1...master
[4.5.1]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.5.0...4.5.1
[4.5.0]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.4.0...4.5.0
[4.4.0]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.3.2...4.4.0
[4.3.2]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.3.1...4.3.2
[4.3.1]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.3.0...4.3.1
[4.3.0]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.2.1...4.3.0
[4.2.1]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.2.0...4.2.1
[4.2.0]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.1.2...4.2.0
[4.1.2]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.1.1...4.1.2
[4.1.1]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.1.0...4.1.1
[4.1.0]:      https://github.com/puppetlabs/puppetlabs-iis/compare/4.0.0...4.1.0
[4.0.0]:      https://github.com/puppetlabs/puppetlabs-iis/compare/0.1.0...4.0.0
