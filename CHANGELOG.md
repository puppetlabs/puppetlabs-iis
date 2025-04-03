<!-- markdownlint-disable MD024 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## [v10.1.1](https://github.com/puppetlabs/puppetlabs-iis/tree/v10.1.1) - 2025-04-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v10.1.0...v10.1.1)

### Fixed

- (CAT-2274): Add support for forms authentication in web administration templates [#401](https://github.com/puppetlabs/puppetlabs-iis/pull/401) ([span786](https://github.com/span786))
- (MODULES-11467) update summary to match platforms [#400](https://github.com/puppetlabs/puppetlabs-iis/pull/400) ([amitkarsale](https://github.com/amitkarsale))

## [v10.1.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v10.1.0) - 2025-03-12

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v10.0.1...v10.1.0)

### Added

- (CAT-2218): Add 'forms' to valid authentication schemas and update validation message [#398](https://github.com/puppetlabs/puppetlabs-iis/pull/398) ([span786](https://github.com/span786))

## [v10.0.1](https://github.com/puppetlabs/puppetlabs-iis/tree/v10.0.1) - 2024-12-17

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v10.0.0...v10.0.1)

## [v10.0.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v10.0.0) - 2023-04-18

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v9.0.0...v10.0.0)

### Changed

- (CONT-782) - add puppet 8 support/Drop puppet 6 support [#367](https://github.com/puppetlabs/puppetlabs-iis/pull/367) ([jordanbreen28](https://github.com/jordanbreen28))

## [v9.0.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v9.0.0) - 2023-02-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v8.1.1...v9.0.0)

### Changed

- (CONT-6) Hardening codebase - Dropping Powershell 2 Support [#355](https://github.com/puppetlabs/puppetlabs-iis/pull/355) ([LukasAud](https://github.com/LukasAud))

## [v8.1.1](https://github.com/puppetlabs/puppetlabs-iis/tree/v8.1.1) - 2022-10-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v8.1.0...v8.1.1)

### Fixed

- (MAINT) Drop support for Windows Server 2008 R2. [#350](https://github.com/puppetlabs/puppetlabs-iis/pull/350) ([jordanbreen28](https://github.com/jordanbreen28))

## [v8.1.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v8.1.0) - 2022-03-14

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v8.0.3...v8.1.0)

### Added

- pdksync - (FM-8922) - Add Support for Windows 2022 [#335](https://github.com/puppetlabs/puppetlabs-iis/pull/335) ([david22swan](https://github.com/david22swan))

### Fixed

- (MODULES-11188) Fix physicalPath on apps and sites [#336](https://github.com/puppetlabs/puppetlabs-iis/pull/336) ([chelnak](https://github.com/chelnak))
- MODULES-11188: trim physicalpath for iis_application resource [#330](https://github.com/puppetlabs/puppetlabs-iis/pull/330) ([adrianiurca](https://github.com/adrianiurca))

## [v8.0.3](https://github.com/puppetlabs/puppetlabs-iis/tree/v8.0.3) - 2021-06-28

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v8.0.2...v8.0.3)

### Fixed

- Correct error handling in require ruby-pwsh [#325](https://github.com/puppetlabs/puppetlabs-iis/pull/325) ([benningm](https://github.com/benningm))

## [v8.0.2](https://github.com/puppetlabs/puppetlabs-iis/tree/v8.0.2) - 2021-05-10

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v8.0.1...v8.0.2)

### Fixed

- (MODULES-9656) - Enable using 0 for application pool settings [#321](https://github.com/puppetlabs/puppetlabs-iis/pull/321) ([pmcmaw](https://github.com/pmcmaw))

## [v8.0.1](https://github.com/puppetlabs/puppetlabs-iis/tree/v8.0.1) - 2021-04-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v8.0.0...v8.0.1)

### Fixed

- (MODULES-10988) fix require_relative being not relative enough [#316](https://github.com/puppetlabs/puppetlabs-iis/pull/316) ([DavidS](https://github.com/DavidS))
- (IAC-1497) - Removal of Unsupported Translate Module [#314](https://github.com/puppetlabs/puppetlabs-iis/pull/314) ([david22swan](https://github.com/david22swan))

## [v8.0.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v8.0.0) - 2021-03-03

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v7.2.0...v8.0.0)

### Changed

- pdksync - Remove Puppet 5 from testing and bump minimal version to 6.0.0 [#308](https://github.com/puppetlabs/puppetlabs-iis/pull/308) ([carabasdaniel](https://github.com/carabasdaniel))

## [v7.2.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v7.2.0) - 2021-01-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v7.1.0...v7.2.0)

### Added

- Add support for Puppet 7 [#302](https://github.com/puppetlabs/puppetlabs-iis/pull/302) ([daianamezdrea](https://github.com/daianamezdrea))
- MODULES-10884 Allow a UNC path as the physical path of a web site [#301](https://github.com/puppetlabs/puppetlabs-iis/pull/301) ([palintir](https://github.com/palintir))

### Fixed

- (IAC-991) - Removal of inappropriate terminology [#293](https://github.com/puppetlabs/puppetlabs-iis/pull/293) ([david22swan](https://github.com/david22swan))

## [v7.1.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v7.1.0) - 2020-07-08

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v7.0.1...v7.1.0)

### Added

- Make iis application physicalpath optional [#282](https://github.com/puppetlabs/puppetlabs-iis/pull/282) ([adrianiurca](https://github.com/adrianiurca))

### Fixed

- (MODULES-10702) Make certificatestorename case insensitive. [#280](https://github.com/puppetlabs/puppetlabs-iis/pull/280) ([nicolasvan](https://github.com/nicolasvan))

## [v7.0.1](https://github.com/puppetlabs/puppetlabs-iis/tree/v7.0.1) - 2020-03-31

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v7.0.0...v7.0.1)

### Fixed

- Fix provider enabledprotocols [#272](https://github.com/puppetlabs/puppetlabs-iis/pull/272) ([johnrogers00](https://github.com/johnrogers00))
- MODULES-10419: Fix error message for net.tcp bindings. [#254](https://github.com/puppetlabs/puppetlabs-iis/pull/254) ([pillarsdotnet](https://github.com/pillarsdotnet))

## [v7.0.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v7.0.0) - 2020-01-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v6.0.0...v7.0.0)

### Changed

- (FM 8426) replace vendored code with pwshlib dependency [#247](https://github.com/puppetlabs/puppetlabs-iis/pull/247) ([david22swan](https://github.com/david22swan))

### Added

- (FM-8195) Convert to Litmus [#249](https://github.com/puppetlabs/puppetlabs-iis/pull/249) ([florindragos](https://github.com/florindragos))

### Fixed

- (MODULES-10362) handle authenticationinfo consistently [#253](https://github.com/puppetlabs/puppetlabs-iis/pull/253) ([pillarsdotnet](https://github.com/pillarsdotnet))
- (MODULES-10361) sort https bindings first [#252](https://github.com/puppetlabs/puppetlabs-iis/pull/252) ([pillarsdotnet](https://github.com/pillarsdotnet))

## [v6.0.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v6.0.0) - 2019-10-30

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/v5.0.0...v6.0.0)

## [v5.0.0](https://github.com/puppetlabs/puppetlabs-iis/tree/v5.0.0) - 2019-07-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.5.1...v5.0.0)

### Changed

- MODULES-9349 - Update puppet minimum version [#227](https://github.com/puppetlabs/puppetlabs-iis/pull/227) ([lionce](https://github.com/lionce))

### Fixed

- (MODULES-7700) Ensure app pool state is idempotent [#222](https://github.com/puppetlabs/puppetlabs-iis/pull/222) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (MODULES-7820) Fix "No Managed Code" in app pool [#221](https://github.com/puppetlabs/puppetlabs-iis/pull/221) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (MODULES-9087) Increase pipe timeout to 180s [#220](https://github.com/puppetlabs/puppetlabs-iis/pull/220) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (MODULES-8381) Support timeformat such as 1.05:00:00 [#202](https://github.com/puppetlabs/puppetlabs-iis/pull/202) ([treydock](https://github.com/treydock))
- (MODULES-8254) Source wasn't being used in iis_feature [#200](https://github.com/puppetlabs/puppetlabs-iis/pull/200) ([bgrossman](https://github.com/bgrossman))

## [4.5.1](https://github.com/puppetlabs/puppetlabs-iis/tree/4.5.1) - 2019-04-01

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.5.0...4.5.1)

### Added

- (FM-7693) Add Windows Server 2019 [#205](https://github.com/puppetlabs/puppetlabs-iis/pull/205) ([glennsarti](https://github.com/glennsarti))
- (MODULES-8346) Case Sensitive Paths [#203](https://github.com/puppetlabs/puppetlabs-iis/pull/203) ([RandomNoun7](https://github.com/RandomNoun7))

### Fixed

- (MODULES-6080) Ensure virtualdir removal idempotent [#209](https://github.com/puppetlabs/puppetlabs-iis/pull/209) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (MODULES-6061) Fix virtual directory update [#208](https://github.com/puppetlabs/puppetlabs-iis/pull/208) ([RandomNoun7](https://github.com/RandomNoun7))

## [4.5.0](https://github.com/puppetlabs/puppetlabs-iis/tree/4.5.0) - 2018-10-23

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.4.0...4.5.0)

### Added

- (MODULES-5493) Manage Two Same Name Appications [#189](https://github.com/puppetlabs/puppetlabs-iis/pull/189) ([RandomNoun7](https://github.com/RandomNoun7))

### Fixed

- (MODULES-7174) Added update method to fix parent provider flush [#170](https://github.com/puppetlabs/puppetlabs-iis/pull/170) ([bFekete](https://github.com/bFekete))

## [4.4.0](https://github.com/puppetlabs/puppetlabs-iis/tree/4.4.0) - 2018-09-04

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.3.2...4.4.0)

### Added

- (MODULES-6947) Add additional protocols [#184](https://github.com/puppetlabs/puppetlabs-iis/pull/184) ([RandomNoun7](https://github.com/RandomNoun7))

### Fixed

- (MODULES-6870) Fix Password Escaping [#180](https://github.com/puppetlabs/puppetlabs-iis/pull/180) ([RandomNoun7](https://github.com/RandomNoun7))

## [4.3.2](https://github.com/puppetlabs/puppetlabs-iis/tree/4.3.2) - 2018-06-13

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.3.1...4.3.2)

### Fixed

- (MODULES-7173) Cannot Start IIS Site with Port 443 [#171](https://github.com/puppetlabs/puppetlabs-iis/pull/171) ([RandomNoun7](https://github.com/RandomNoun7))
- (MODULES-6928) Fix Pipe Server on Win 2008r2 [#166](https://github.com/puppetlabs/puppetlabs-iis/pull/166) ([RandomNoun7](https://github.com/RandomNoun7))
- Revert "(IMAGES-795) 2008r2 template failing PowerShell module tests" [#165](https://github.com/puppetlabs/puppetlabs-iis/pull/165) ([RandomNoun7](https://github.com/RandomNoun7))
- (IMAGES-795) 2008r2 template failing PowerShell module tests [#164](https://github.com/puppetlabs/puppetlabs-iis/pull/164) ([glennsarti](https://github.com/glennsarti))

## [4.3.1](https://github.com/puppetlabs/puppetlabs-iis/tree/4.3.1) - 2018-03-21

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.3.0...4.3.1)

### Added

- (MODULES-6637) Port Conflict Hostname Only [#158](https://github.com/puppetlabs/puppetlabs-iis/pull/158) ([RandomNoun7](https://github.com/RandomNoun7))
- (MODULES-6673) Ensure Present IIS Site Loop [#157](https://github.com/puppetlabs/puppetlabs-iis/pull/157) ([RandomNoun7](https://github.com/RandomNoun7))
- (MODULES-5229) Add authenticationinfo to iis_site [#109](https://github.com/puppetlabs/puppetlabs-iis/pull/109) ([jpogran](https://github.com/jpogran))

### Fixed

- (MODULES-6208) Should support Sensitive datatype [#159](https://github.com/puppetlabs/puppetlabs-iis/pull/159) ([RandomNoun7](https://github.com/RandomNoun7))

## [4.3.0](https://github.com/puppetlabs/puppetlabs-iis/tree/4.3.0) - 2018-01-26

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.2.1...4.3.0)

### Added

- (MODULES-5465) add puppet feature suitability [#151](https://github.com/puppetlabs/puppetlabs-iis/pull/151) ([jpogran](https://github.com/jpogran))
- (MODULES-6385) Create site with alternate port [#150](https://github.com/puppetlabs/puppetlabs-iis/pull/150) ([RandomNoun7](https://github.com/RandomNoun7))
- (MODULES-6283) Update the PowerShell Manager [#143](https://github.com/puppetlabs/puppetlabs-iis/pull/143) ([RandomNoun7](https://github.com/RandomNoun7))
- (MODULES-6144) Add Limits to IIS Site Type and Provider [#141](https://github.com/puppetlabs/puppetlabs-iis/pull/141) ([michaeltlombardi](https://github.com/michaeltlombardi))

### Fixed

- (MODULES-6257) Fix Applications in Nested Subfolders [#152](https://github.com/puppetlabs/puppetlabs-iis/pull/152) ([RandomNoun7](https://github.com/RandomNoun7))
- (MODULES-6166) virtual_directory requires sitename [#138](https://github.com/puppetlabs/puppetlabs-iis/pull/138) ([Iristyle](https://github.com/Iristyle))

## [4.2.1](https://github.com/puppetlabs/puppetlabs-iis/tree/4.2.1) - 2017-12-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.2.0...4.2.1)

### Added

- (MODULES-6195) Add user_name and password support to iis_virtual_directory [#134](https://github.com/puppetlabs/puppetlabs-iis/pull/134) ([tkishel](https://github.com/tkishel))

### Fixed

- (MODULES-6062) Fix iis_virtual_directory idempotency [#136](https://github.com/puppetlabs/puppetlabs-iis/pull/136) ([jpogran](https://github.com/jpogran))
- (MODULES-6069) iis_site applicationpool does not allow valid characters [#133](https://github.com/puppetlabs/puppetlabs-iis/pull/133) ([tkishel](https://github.com/tkishel))
- (MODULES-5264) allow UNC PhysicalPath in iis_virtual_directory [#132](https://github.com/puppetlabs/puppetlabs-iis/pull/132) ([tkishel](https://github.com/tkishel))
- (MODULES-6020) Fix iis_application setting applicationpool [#130](https://github.com/puppetlabs/puppetlabs-iis/pull/130) ([nickadcock-bango](https://github.com/nickadcock-bango))
- (MODULES-5954) Fix constant reassignment [#129](https://github.com/puppetlabs/puppetlabs-iis/pull/129) ([glennsarti](https://github.com/glennsarti))

## [4.2.0](https://github.com/puppetlabs/puppetlabs-iis/tree/4.2.0) - 2017-11-08

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.1.2...4.2.0)

## [4.1.2](https://github.com/puppetlabs/puppetlabs-iis/tree/4.1.2) - 2017-11-02

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.1.1...4.1.2)

### Added

- (MODULES-5801)(MODULES-5803) Add IIS 10.0 support [#123](https://github.com/puppetlabs/puppetlabs-iis/pull/123) ([glennsarti](https://github.com/glennsarti))
- (MODULES-5626) IIS Application Pool Name Validation [#119](https://github.com/puppetlabs/puppetlabs-iis/pull/119) ([jpogran](https://github.com/jpogran))
- (MODULES-5521) IIS support for net.pipe protocol [#118](https://github.com/puppetlabs/puppetlabs-iis/pull/118) ([nickadcock-bango](https://github.com/nickadcock-bango))

### Fixed

- (MODULES-5627) Fix iis_application applicationpoolname validation [#122](https://github.com/puppetlabs/puppetlabs-iis/pull/122) ([jpogran](https://github.com/jpogran))
- (MODULES-5627) Fix IIS application name validation for puppet resource [#121](https://github.com/puppetlabs/puppetlabs-iis/pull/121) ([glennsarti](https://github.com/glennsarti))
- (MODULES-5627) Fix IIS application name validation [#120](https://github.com/puppetlabs/puppetlabs-iis/pull/120) ([jpogran](https://github.com/jpogran))
- (MODULES-5344) iis_virtual_directory handle slashes in name [#91](https://github.com/puppetlabs/puppetlabs-iis/pull/91) ([tkishel](https://github.com/tkishel))

## [4.1.1](https://github.com/puppetlabs/puppetlabs-iis/tree/4.1.1) - 2017-09-25

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.1.0...4.1.1)

### Added

- (MODULES-5576) Confine IIS Version for preloadenabled [#110](https://github.com/puppetlabs/puppetlabs-iis/pull/110) ([jpogran](https://github.com/jpogran))

### Fixed

- (MODULES-5443) Fix IIS Site Name Validation [#113](https://github.com/puppetlabs/puppetlabs-iis/pull/113) ([michaeltlombardi](https://github.com/michaeltlombardi))
- (MODULES-5576) Confine specs for preloadenabled [#112](https://github.com/puppetlabs/puppetlabs-iis/pull/112) ([jpogran](https://github.com/jpogran))
- (Modules-5576) Fix IIS 7.5 Support [#111](https://github.com/puppetlabs/puppetlabs-iis/pull/111) ([jpogran](https://github.com/jpogran))
- (MODULES-5576) Fix: iis_site Preload Enabled Not Working [#108](https://github.com/puppetlabs/puppetlabs-iis/pull/108) ([ferventcoder](https://github.com/ferventcoder))
- (MODULES-5381) managed_runtime_version should allow the 'No Managed Code' value [#94](https://github.com/puppetlabs/puppetlabs-iis/pull/94) ([carlosfbteixeira](https://github.com/carlosfbteixeira))

## [4.1.0](https://github.com/puppetlabs/puppetlabs-iis/tree/4.1.0) - 2017-08-15

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/4.0.0...4.1.0)

### Added

- (MODULES-5125) Enable update IIS properties [#84](https://github.com/puppetlabs/puppetlabs-iis/pull/84) ([jpogran](https://github.com/jpogran))

### Fixed

- (MODULES-5429) Fix iis_site idempotency [#101](https://github.com/puppetlabs/puppetlabs-iis/pull/101) ([jpogran](https://github.com/jpogran))
- (MODULES-5259) Handle nil values [#95](https://github.com/puppetlabs/puppetlabs-iis/pull/95) ([hunner](https://github.com/hunner))
- (MODULES-5169) iis_application_pool not idempotent [#93](https://github.com/puppetlabs/puppetlabs-iis/pull/93) ([tkishel](https://github.com/tkishel))
- (MODULES-5259) Accept both uppercase and lowercase thumbprints [#89](https://github.com/puppetlabs/puppetlabs-iis/pull/89) ([hunner](https://github.com/hunner))

## [4.0.0](https://github.com/puppetlabs/puppetlabs-iis/tree/4.0.0) - 2017-06-05

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/0.1.0...4.0.0)

### Added

- (MODULES-4563) Add Windows 2008R2 support of iis_application [#67](https://github.com/puppetlabs/puppetlabs-iis/pull/67) ([glennsarti](https://github.com/glennsarti))
- (MODULES-3053) IIS virtual directory [#66](https://github.com/puppetlabs/puppetlabs-iis/pull/66) ([jpogran](https://github.com/jpogran))
- (MODULES-3050) Add iis_application [#49](https://github.com/puppetlabs/puppetlabs-iis/pull/49) ([hunner](https://github.com/hunner))

### Fixed

- (MODULES-4976) Remove rspec configuration for win32_console [#76](https://github.com/puppetlabs/puppetlabs-iis/pull/76) ([glennsarti](https://github.com/glennsarti))
- (MODULES-4297) iis_site should autorequire the iis_application_pool [#73](https://github.com/puppetlabs/puppetlabs-iis/pull/73) ([glennsarti](https://github.com/glennsarti))
- (MODULES-4762) Fix error message for SSL settings on HTTP binding [#69](https://github.com/puppetlabs/puppetlabs-iis/pull/69) ([glennsarti](https://github.com/glennsarti))
- Correct method name [#62](https://github.com/puppetlabs/puppetlabs-iis/pull/62) ([binford2k](https://github.com/binford2k))
- (MODULES-4601) Fail correctly when rototiller gem is not present [#58](https://github.com/puppetlabs/puppetlabs-iis/pull/58) ([ThoughtCrhyme](https://github.com/ThoughtCrhyme))
- (MODULES-4464) Fix Set-ItemProperty use [#57](https://github.com/puppetlabs/puppetlabs-iis/pull/57) ([jpogran](https://github.com/jpogran))
- (MODULES-4484) Fix bug in ConvertTo-JSON on Windows 2008 [#50](https://github.com/puppetlabs/puppetlabs-iis/pull/50) ([glennsarti](https://github.com/glennsarti))
- (MODULES-4464) Remove Appcmd [#46](https://github.com/puppetlabs/puppetlabs-iis/pull/46) ([jpogran](https://github.com/jpogran))

## [0.1.0](https://github.com/puppetlabs/puppetlabs-iis/tree/0.1.0) - 2017-03-16

[Full Changelog](https://github.com/puppetlabs/puppetlabs-iis/compare/457bd0aab9e6e775696c9e76d3e9220b5b2fc24c...0.1.0)
