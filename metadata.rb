name 'cb_dvo_logging'
maintainer 'Ray Crawford'
maintainer_email 'ray_crawford@trekbikes.com'
license 'All Rights Reserved'
description 'Installs/Configures cb_dvo_logging'
long_description 'Installs/Configures cb_dvo_logging'
version '2.2.10'

source_url 'https://bitbucket.org/trekbikes/cb_dvo_logging'
issues_url 'https://bitbucket.org/trekbikes/cb_dvo_logging/issues?status=new&status=open'

chef_version '>= 12.1' if respond_to?(:chef_version)
supports 'centos'

depends 'sumologic-collector', '~> 1.2.23'
depends 'cb_dvo_addStorage'
depends 'cb_dvo_localAccounts'
depends 'cb_dvo_adJoin'
