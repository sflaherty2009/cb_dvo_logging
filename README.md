# cb_dvo_logging

* Configures the necessary directories
* Installs/starts SumoLogic
* Places environment-specific user.properties with keys
* Places use-specific sources.json files

Docker mounts use-specific external volumes `/opt/sumologs/solr`, `/opt/sumologs/apache` or `/opt/sumologs/hybris` based upon the VM hostname (which determines what kind of Docker container is placed on the VM).  In this implementation, `/opt/sumologs` is a symbolic link to `/standard/sumologs`.  For details about what this filesystem is, see cb_dvo_addStorage.

# Environment Pinning

* production: 2.0.4
* staging: 2.0.4
* testing: latest
* development: latest

# Requirements

## Supported Platforms

* CentOS 7

## Chef

* Chef 12+

## Dependent Cookbooks

* cb_dvo_addStorage

## Attributes (significant)

### node['dvo_user']['use']

A space delimited set of VM uses.  Anything can be in the list, but it must have one or more of the following:
* hybrisFrontEndWebServer
* hybrisBackEndWebServer
* hybris
* linux

This attribute is used in two places.  First, if it contains `\bsolr\b`,`\bhybris\b` or `\bhybris\S*WebServer\b` the appropriate `/standard/sumologs/` directories will be created.  This must be done ***before*** the wcp_deploy.sh script is run if Docker is used on the VM.  The second place it is used is to select what part(s) of the sources.json.erb template are dropped.

### node['dvo_user']['ALM_environment']

A short representation of the environment used to configure the _sourceCategory in SumoLogic.  For example:

* ss = Shared Services
* prod = Production
* e2e = End to End testing environment
* local = local host testing
* ...

## Attributes (others)

### default['sumologic']['url']

The location of the download.

* Current value: 'https://collectors.sumologic.com/rest/download/rpm/64'

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

* Implement this cookbook on the Windows platform ([DVO-2352](https://trekbikes.atlassian.net/browse/DVO-2352))

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
