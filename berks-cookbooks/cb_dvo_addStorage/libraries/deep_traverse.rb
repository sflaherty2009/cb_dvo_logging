def deep_traverse(h = {})
  stack = h.map { |k, v| [[k], v] }
  retobj = {}
  until stack.empty?
    key, value = stack.pop
    retobj[key] = value
    value.each { |k, v| stack.push [key.dup << k, v] } if value.is_a? Hash
  end
  retobj
end
