name 'build_cookbook'
maintainer 'The Authors'
maintainer_email 'you@example.com'
license 'all_rights'
version '0.1.2'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'delivery-truck'
depends 'terraform', '~> 2.1.1'
