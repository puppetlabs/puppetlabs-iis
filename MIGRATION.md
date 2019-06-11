# Migrating from puppet-iis to puppetlabs-iis

When migrating from puppet-iis to puppetlabs-iis, most functionality can be directly mapped over as described below. Any functionality that is not directly mapped is described towards the end of the document.

## Mapped functionality from VP -> PL

### `iis_pool`

This type is now called `iis_application_pool`

#### Parameter mapping:

puppet-iis    | puppetlabs-iis
--------------|--------------
ensure        | identical
name          | identical
enable_32_bit | enable32_bit_app_on_win64
runtime       | managed_runtime_version
pipeline      | managed_pipeline_mode

### `iis::manage_app_pool`

All of these properties are managed directly by the `iis_application_pool` resource and are not declared separately, as the `iis_pool` and `iis::manage_app_pool` resources are.

#### Parameter mapping:

puppet-iis                       | puppetlabs-iis
---------------------------------|--------------
app_pool_name                    | not needed
enable_32_bit                    | enable32_bit_app_on_win64
managed_runtime_version          | identical
managed_pipeline_mode            | identical
ensure                           | identical
start_mode                       | identical
rapid_fail_protection            | identical
apppool_identitytype             | identity_type
apppool_username                 | user_name
apppool_userpw                   | password
apppool_idle_timeout_minutes     | idle_timeout
apppool_max_processes            | max_processes
apppool_max_queue_length         | queue_length
apppool_recycle_periodic_minutes | restart_time_limit
apppool_recycle_schedule         | restart_schedule
apppool_recycle_logging          | log_event_on_recycle
apppool_idle_timeout_action      | idle_timeout_action

### `iis_site`

This type is still called `iis_site`

#### Parameter mapping:

puppet-iis  | puppetlabs-iis
------------|--------------
ensure      | identical
name        | identical
path        | physicalpath
app_pool    | applicationpool
host_header | bindings hostname*
protocol    | bindings protocol*
ip          | bindings bindinginformation*
port        | bindings bindinginformation*
ssl         | bindings sslflags*

\* The `bindings` parameter on the new `iis_site` takes an array of one or more bindings as a hash and has the following keys per hash:
- protocol
- bindinginformation
- sslflags

The `bindinginformation` value is in the form `<ip>:<port>`

### `iis::manage_binding`

All of these properties are managed directly by the `iis_site::bindings` property and are not declared separately, as the `iis_site` and `iis::manage_binding` resources are. The `iis_site::bindings` hash keys for the map are as follows:

#### Parameter mapping:

puppet-iis             | puppetlabs-iis
-----------------------|--------------
site_name              | not needed
ensure                 | not needed
require_site           | not needed
protocol               | identical
host_header            | hostname
ip_address             | first half of bindinginformation
port                   | last half of bindinginformation
certificate_thumbprint | certificatehash
store                  | certificatestorename
ssl_flag               | sslflags

### `iis_application`

This type is still called `iis_application`

#### Parameter mapping:

puppet-iis | puppetlabs-iis
-----------|--------------
ensure     | identical
name       | identical
path       | physicalpath
site       | sitename *
app_pool   | applicationpool

\* `site` is a reserved word in puppet 4 and will cause failures, so `sitename` is the new name.

### `iis_virtualdirectory`

This type is now called `iis_virtual_directory`

#### Parameter mapping:

puppet-iis | puppetlabs-iis
-----------|--------------
ensure     | identical
name       | identical
path       | physicalpath
site       | sitename *
app_pool   | applicationpool

\* `site` is a reserved word in puppet 4 and will cause failures, so `sitename` is the new name.

## Unmapped functionality

### Class iis

Declares six groups of features via `iis::features::*` to allow them to be easily installed. This functionality is available via `iis_feature` but must be explicitly declared. Please see README.md for information.

The list of feature groups are:
- application deployment
- common http
- health and diagnostics
- management tools
- performance
- security
