name 'build_cookbook'
maintainer 'DevOps'
maintainer_email 'devops@examples.com'
license 'all_rights'
version '0.1.5'
chef_version '>= 12.1' if respond_to?(:chef_version)
source_url 'https://bitbucket.org/examples/build_cookbook'
issues_url 'https://bitbucket.org/examples/build_cookbook/issues?status=new&status=open'

supports 'ubuntu'

depends 'delivery-truck'
depends 'cb_infra_acceptance'
