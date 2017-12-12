# 2.0.4
**Date: 12/12/2017**

* Added rules for Translations logging sources

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
