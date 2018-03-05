def set_storage_attributes(key, storage_class)
  if storage_class == 'standard'
    key.inject(node.normal['dvo_user']) { |acc, elem| acc[elem] }['storage_class'] = 'standard'
    key.inject(node.normal['dvo_user']) { |acc, elem| acc[elem] }['windows_drive'] = 'S'
  else
    key.inject(node.normal['dvo_user']) { |acc, elem| acc[elem] }['storage_class'] = 'premium'
    key.inject(node.normal['dvo_user']) { |acc, elem| acc[elem] }['windows_drive'] = 'P'
  end
end

def lock_storage_class(key)
  key.inject(node.normal['dvo']['storage']) { |acc, elem| acc[elem] }['storage_class_set'] = true
end
