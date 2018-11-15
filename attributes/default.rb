default['dvo_user']['sumologic']['storage_class'] = 'standard'
default['dvo_user']['sumologic']['accessID'] = 'surjan05DU9ut2'
default['dvo_user']['sumologic']['accessKey'] = 'LlgS3jojH7LXJxv1UnbaLj1ZPXN38oWZXLDXJqRJ59rTA6xjVwQ0XrP08pf2o4YV'
default['sumologic']['server_type'] =
  if node['cookbooks'].attribute?('cb_dvo_freegeoip')
    'freegeoip'
  elsif node['cookbooks'].attribute?('cb_dvo_solr')
    'solr'
  elsif node['cookbooks'].attribute?('cb_dvo_hybris')
    'hybris'
  elsif node['cookbooks'].attribute?('cb_dvo_web')
    'apache'
  else
    nil
  end
