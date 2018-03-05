def storage_classes_set?(dvo, dvo_user)
  val = true
  temp_dvo = {}
  if dvo.key?('storage')
    temp_dvo = deep_traverse(dvo['storage']) { |path, value| p [path, value] }
  end

  deep_traverse(dvo_user) { |path, value| p [path, value] }.each do |key, _value|
    key_last = key.last
    key_rest = key[0...-1]
    if key_last == 'storage_class'
      if key != []
        if !temp_dvo.key?(key_rest) || (temp_dvo[key_rest].key?('storage_class_set') && !temp_dvo[key_rest]['storage_class_set'])
          val = false
        end
      elsif !temp_dvo.key?(['storage_class_set']) || !temp_dvo[['storage_class_set']]
        val = false
      end
    end
  end
  val
end
