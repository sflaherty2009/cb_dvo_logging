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

* Added logic to parameterize the root category based on 'use' attribute values. Uses www.trekbikes.com by default.

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

* Added guard against 'trekdevs' group missing

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
