name 'build_cookbook'
maintainer 'DevOps'
maintainer_email 'devops@trekbikes.com'
license 'all_rights'
version '0.1.4'
chef_version '>= 12.1' if respond_to?(:chef_version)
source_url 'https://bitbucket.org/trekbikes/build_cookbook'
issues_url 'https://bitbucket.org/trekbikes/build_cookbook/issues?status=new&status=open'

supports 'ubuntu'

depends 'delivery-truck'
depends 'terraform', '~> 2.1.1'
