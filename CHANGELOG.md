# 2.3.3
**Date: 1/17/2019**

* Modified delivery to use cb_infra_acceptance instead of cb_dvo_terraform.

# 2.3.2
**Date: 1/7/2019**

* Configured Sumologic installation to depend on sources.json and reinstall if sources.json changes.

# 2.3.1
**Date: 1/7/2019**

* Added cron job to clean up and compress old hybris logs that aren't otherwise dealt with (access).
* Separated hybris logs into proper categories again (access, application and gc).

# 2.3.0
**Date: 12/18/2018**

* Moved from encrypted data bags to Chef Vault
* Cleaned up kitchen.yml

# 2.2.30
**Date: 11/15/2018**

* Set attribute to nil on else
* Had recipe check to see if recipe is nil as opposed to set as it was always being set

# 2.2.29
**Date: 11/14/2018**

* Added log rotations for solr and freegeoip
* Added an attribute to create server specific log folders based on node['cookbooks']
* Updated block to create server specific log folders and log rotation
* Removed all translations references from sources.json.erb

# 2.2.28
**Date: 11/11/2018**

* Added a missed ephemeral property in the windows recipe.

# 2.2.27
**Date: 11/9/2018**

* Just changing the wording related to platforms in the spec recipes.

# 2.2.26
**Date: 11/8/2018**

* Fixed windows spec test to specify a windows runner.

# 2.2.25
**Date: 11/8/2018**

* Added windows supports directive to metadata.

# 2.2.24
**Date: 11/7/2018**

* Changed cookbook dependency names.
* Fixed attribute issue.

# 2.2.23
**Date: 11/5/2018**

* Rolled back change switching to encrypted data bags.

# 2.2.22
**Date: 11/5/2018**

* Updating cb_dvo_addStorage dependency.

# 2.2.21
**Date: 10/28/2018**

* Fixing ephemeral collector property.
* Updated to use encrypted data bags.
* Added functional test which uses the Sumologic API to verify the collector was added and is alive.

# 2.2.20
**Date: 10/19/2018**

* Removing OMS/auditd cleanup code.

# 2.2.19
**Date: 10/18/2018**

* Cleaning up leftover OMS/auditd rules.

# 2.2.18
**Date: 10/17/2018**

* Reverting OMS/auditd logging changes.

# 2.2.17
**Date: 9/24/2018**

* Fix for recent OMS/auditd system call logging.

# 2.2.15
**Date: 8/17/2018**

* Added logrotation configuration for azure logs.

# 2.2.12 - 2.2.14
**Date: 8/12/2018**

* Quick hotfix. There was an issue with the web node log rotation.

# 2.2.11
**Date: 7/27/2018**

* Updated sources.json to use cutoffRelativeTime instead of cutoffTimestamp pulling a maximum of one hour into the past. This goes by modified date of the log file, so log rotation needs to be configured appropriately as well.
* Configure logrotate to run hourly rather than daily.
* Cleaned up sources.json whitespace issues.

# 2.2.2
**Date: 3/26/2017**

* Fixed issue caused by nsswitch.conf being changed during the chef run on first converge while joining the AD. Apparently a process already running (including chef) must be restarted to gain access to user/group changes if nsswitch.conf changes. Since chef initiates joining the AD, this means it would be required to restart. I worked around this by shelling out to a new process to find the group ID and using that instead, which chef is fine with.

# 2.2.1
**Date: 3/25/2017**

* Fixed to allow creation of folders and update group ownership later to avoid problems with containers creating the folders first.

# 2.2.0
**Date: 3/22/2017**

* Modified linux recipe to leverage built in Chef idempotence instead of compile time guards.
* Refactored to allow all resources to be skipped if up to date.
* Implemented clobber flag to replace collectors on machine rebuilds
  * Note this will require we be careful about naming to avoid unwanted overwriting of collectors

# 2.1.0
**Date: 3/20/2018**

There were many changes in this release.
* Simplified .kitchen.yml, placing more in the platforms and streamlining the suites
* Renamed platforms to enable easier platform-wide testing, in isolation
* Fixed an issue with the creation of the solr directory in /standard/sumologs/solr
* Added comments to clarify future (needed) refactoring

# 2.0.14
**Date: 3/20/2018**

* Incremented versions to push some random changes done previously to the Chef server in an attempt to debug other issues.

# 2.0.14
**Date: 3/13/2017**

* Added vertex log locations

# 2.0.13
**Date: 3/08/2017**

* Update epoch in freegeoip template

# 2.0.12
**Date: 3/08/2017**

* Added freegeoip section to template

# 2.0.11
**Date: 3/02/2017**

* Refactored to remove storage class attribute logic now in cb_dvo_addStorage

# 2.0.10
**Date: 2/27/2017**

* Configured to use storage class attributes

# 2.0.8
**Date: 2/20/2018**
**Change by: Ray Crawford**
**Feature branch: DVO-2775**

* Updated so /standard/sumologs/solr is owned by solr and readable by developers

# 2.0.7
**Date: 12/13/2017**

* Added logic to parameterize the root category based on 'use' attribute values. Uses www.examples.com by default.

# 2.0.6
**Date: 12/12/2017**

* Added rules for Apache logs

# 2.0.5
**Date: 12/12/2017**

* Updated source category naming

# 2.0.4
**Date: 12/12/2017**

* Added rules for Translations logging sources

# 2.0.3
**Date: 12/12/2017**

* Removed Docker STDOUT logging

# 2.0.2
**Date: 12/02/2017**
**Contributor: Matt Oleksowicz**

* Added guard against 'exmpldevs' group missing

# 2.0.0
**Date: 11/15/2017**
**Contributor: Ray Crawford**

* Refactored to place logs on /standard in Linux

# 1.0.7
**Date: 9/2/2017**

* Added user.properties entry for '-prd-'
* Added user.properties entry for '-tst-'
* Added user.properties entry for '-ssn-'
* Added user.properties entry for '-tf-'
* Added user.properties entry for '-mdn-'
* Added user.properties entry for '-dmn-'
* Removed issue with RPM checksum...
  * Since I can't specify the version I want from Sumo, when a new one, with a new checksum is released, it broke the script.  Since updates are low impact, removed checksum.  Can be added again if we leverage a artifactory to deliver assets such as these.

# 1.0.6
**Data: 8/15/2017**

* Added user.properties entry for '-geoip-'
* Updated the template error to actually print the env name that doesn't match in the user.properties

# 1.0.5
**Data: 7/7/2017**

* Moved sumologic attributes into the dvo_user namespace
* Significant updates to documentation

# 1.0.4
**Data: 7/7/2017**

* Release version
