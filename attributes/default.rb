default['dvo_user']['sumologic']['storage_class'] = 'standard'
default['chef-vault']['version'] = '3.4.3'
default['sumologic']['server_type'] =
  if node['cookbooks'].attribute?('cb_dvo_freegeoip')
    'freegeoip'
  elsif node['cookbooks'].attribute?('cb_dvo_solr')
    'solr'
  elsif node['cookbooks'].attribute?('cb_dvo_hybris')
    'hybris'
  elsif node['cookbooks'].attribute?('cb_dvo_web')
    'apache'
  end
