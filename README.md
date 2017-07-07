# cb_dvo_logging

* Configures the necessary directories
* Installs/starts SumoLogic
* Places environment-specific user.properties with keys
* Places use-specific sources.json files

As an FYI, Docker drops logs to `/opt/sumologs/` apache or hybris directories.  These are linked to directories on /mnt/resource.  The result is that the logs are stored on free, ***ephemeral*** storage.  This is relevant in that it could cause a loss of logs if the VM logs an error and immediately chokes before the data can be shipped to SumoLogic.  An item has been placed in the tech debt to create the files on perminent storage and then rotate off to ephemermal before destroying.

# Environment Pinning

* production: 1.0.5
* staging: 1.0.5
* testing: 1.0.5
* development: latest

# Requirements

## Supported Platforms

* CentOS 73

## Chef

* Chef 12+

## Dependent Cookbooks

* None

## Attributes (significant)

### node['dvo_user']['use']

A space delimited set of VM uses.  Anything can be in the list, but it must have one or more of the following:
* hybrisFrontEndWebServer
* hybrisBackEndWebServer
* hybris
* linux

This attribute is used in two places.  First, if it contains `\bhybris\b` or `\bhybris\S*WebServer\b` the appropriate `/opt/sumologs/` directories will be created.  This must be done ***before*** the wcp_deploy.sh script is run if Docker is used on the VM.  The second place it is used is to select what part(s) of the sources.json.erb template are dropped.

### node['dvo_user']['ALM_environment']

A short representation of the environment used to configure the _sourceCategory in SumoLogic.  For example:

* ss = Shared Services
* prod = Production
* e2e = End to End testing environment
* local = local host testing
* ...

## Attributes (others)

### default['dvo_user']['sumologic']['version']

Simply sets a value used as a string in naming what is installed.  Does not affect the version of what is pulled down.

Put in the dvo_user name space so that it can be overloaded via the orchestrator at provisioning time.

* Current value: '19.182-44'

### default['dvo_user']['sumologic']['checksum']

SHA256 of the current SumoLogic collector binary (19.182.44, currently).  This is used to make sure the local copy of the binaries matches that SHA.  If it doesn't, it downloads the latest version from SumoLogic and upgrades to it.  This is done to speed up the converges.

This could cause a problem if, at provisioning time, a newer version is downloaded from SumoLogic before this attribute is updated.  This would cause it to download and install the collector with every run, every 30 minutes.

Put in the dvo_user name space so that it can be overloaded via the orchestrator at provisioning time.

* Current value: '2d6390ca9cbe2370e728e42ffb892e900ee31e1f3fd8aa82d1d6714731165638'

### default['sumologic']['url']

The location of the download.

* Current value: 'https://collectors.sumologic.com/rest/download/rpm/64'

### default['sumologic']['package_name']

Just a string used to provide useful logging...

* Current value: "SumoCollector #{default['sumologic']['version']}"

# Recipes

## cb_dvo_logging::linux

## cb_dvo_logging::windows

### NOT IMPLEMENTED YET

# Usage

* Must be run before containers are started; the directories created are mounted in the `docker run` command
  * FYI: if the wcp_deploy.sh script is used, the containers will start just fine as the `docker run` command is built interactively based upon the presence of directories
* This is **not included in the base run_list**

## At provisioning time
* Configure the folowing block in the Orchestrator's resource JSON for the specific VM 

```
          "chefAttributes": {
            "use": "vertex linux",
            "ALM_environment": "ss"
          }          

```
* Add cb_dvo_logging to the Orchestrator's resource JSON for the specific VM

```
          "run_list": "recipe['cb_dvo_logging']",
```

## After provisioning

* Via Knife or the Chef Manage UI (does not work with Orchestrator redeployment):
  * Update the node['dvo_user']['use'] with a list of VM uses
  * Update the node['dvo_user']['ALM_environment'] attribute
  * If doing on a Hybris or Apache node running in a container, stop the container, delete `/opt/sumologs`
  * Add the cb_dvo_logging cookbook to the VM
  * If needed, delete the container and the image and rerun `/data/deploy/wcp_deploy.sh` after ensuring that a newer container has not been deployed

## Planned & Unplanned Tech Debt

* Store logs, short term, on perminent storage and rotate off to ephemeral before destruction.

# Tests

## Linux

* sources.json content check
  * Does it exist
  * Does it contain the expected content

* user.properties content check
  * It should not include the default line of "#accessid = [accessId]"

* SumoLogic binary
  * installed, enabled and running
  * Appropriate links from /opt/sumologs have been created to /mnt/resource/sumologs based upon value of `node['dvo_user']['use']`

## Windows

### NOT IMPLEMENTED YET

# Contributing

Managed via feature branch pull requests.  Must pass all tests and include new tests for additional functionality/templates.

# License & Authors

**Aurthor:** Ray Crawford (Ray_Crawford@trekbikes.com)

**Copyright:** 2017, The Trek Bicycle Corporation, All Rights Reserved
