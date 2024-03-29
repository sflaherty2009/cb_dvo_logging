# cb_dvo_logging

* Configures the necessary directories
* Installs/starts SumoLogic
* Places use-specific sources.json files
* Ensures logrotate is running hourly on Linux
* Adds logrotate configuration files as appropriate on Linux
* Creates ephemeral collectors in non-production environments.

# Requirements

## Supported Platforms

* CentOS 7
* Windows 2016

## Chef

* Chef 12+

## Dependent Cookbooks

* sumologic-collector
* cb_dvo_addstorage
* cb_dvo_localAccounts
* cb_dvo_adjoin

## Attributes (significant)

### node['hostname'].split('-')[1]

A short representation of the environment used to configure the _sourceCategory in SumoLogic.  For example:

* ss = Shared Services
* prod = Production
* e2e = End to End testing environment
* local = local host testing
* ...

### node['dvo_user']['sumologic']['storage_class']

Define to use 'standard' or 'premium' storage. Generally this should always be 'standard' for this cookbook.

### node['sumologic']['server_type']

Defines the type of server this cookbook is being run on. Current list of possibilities:

* solr
* freegeoip
* hybris
* apache

This attribute is set automatically when run with the respective cookbook tied to the server type from above. It will not be set for any other cookbooks. This can be tested by adding one of the cookbooks from above as a dependancy to metadata.rb and running test kitchen. For example:

```
depends 'cb_dvo_freegeoip'
```

# Recipes

## cb_dvo_logging::linux

Docker mounts use-specific external volumes `/standard/sumologs/solr`, `/standard/sumologs/apache` or `/standard/sumologs/hybris` based upon the VM hostname (which determines what kind of Docker container is placed on the VM).  In this implementation, `/opt/sumologs` is a symbolic link to `/standard/sumologs`.  For details about what this filesystem is, see cb_dvo_addStorage.

Utilizing the sumologic-collector community cookbook, `sources.json` is created via `/templates/sources.json.erb` based upon the VM's hostname. The sumologic collector is then installed and run by using this file.

```
sumologic_collector '/opt/SumoCollector/' do
  collector_name node['hostname']
  clobber true 
  sumo_access_id sumologic_credentials['accessid']
  sumo_access_key sumologic_credentials['accesskey']
  sources '/opt/SumoCollector/config/sources.json'
  sensitive true
end
```

In this example, the collector is created with the same name as the VM. With clobber flagged as true, if this collector is recreated, it will be created over the top and replace the old one rather than creating a secondary collector with the same name. Sources is the file in which the collector is installed with, which tells sumo what logs to send. This file must be created before the installation. Ideally the accessID and key will be encrypted data bags in the future as opposed to plaintext attributes.

## cb_dvo_logging::windows

Utilizing the sumologic-collector community cookbook, `windows.json` is created via the sumo_source_local_windows_event_log block. The sumologic collector is then installed and run by using this file.

```
sumo_source_local_windows_event_log 'windows' do
  source_json_directory node['sumologic']['sumo_json_path']
  category "www.examples.com/#{node['hostname'].split('-')[1]}/windows"
  log_names ['security', 'application']
end
```

The above example creates `windows.json` at the default sumo_json_path (`c:\sumo\`). This can be changed by updating the `node['sumologic']['sumo_json_path']` attribute. With this block we're able to set the category used by sumo as well as which event logs we'd like to export. Currently we're exporting security and application logs.

```
sumologic_collector 'C:\sumo' do
  collector_name node['hostname']
  clobber true
  sources "#{node['sumologic']['sumo_json_path']}/windows.json"
  sumo_access_id sumologic_credentials['accessid']
  sumo_access_key sumologic_credentials['accesskey']
  sensitive true
end
```

In this example, the collector is created with the same name as the VM. With clobber flagged as true, if this collector is recreated, it will be created over the top and replace the old one rather than creating a secondary collector with the same name. Sources is the file in which the collector is installed with, which tells sumo what logs to send. This file must be created before the installation. Ideally the accessID and key will be encrypted data bags in the future as opposed to plaintext attributes.

# Usage

* Place the cookbook in the runlist before any cookbook that creates and runs containers.

# Tests

## Linux

* sources.json content check
  * Does it exist
  * Does it contain the expected content

* user.properties content check
  * It should not include the default line of "#accessid = [accessId]"

* SumoLogic binary
  * installed, enabled and running
  * Appropriate links from /opt/sumologs have been created to /mnt/resource/sumologs based upon value of `node['hostname']`

## Windows

# Contributing

Managed via feature branch pull requests.  Must pass all tests and include new tests for additional functionality/templates.

# License & Authors

**Aurthor:** ExmpleDevOps (devops@examples.com)

**Copyright:** 2018, The Exmple Corporation, All Rights Reserved
