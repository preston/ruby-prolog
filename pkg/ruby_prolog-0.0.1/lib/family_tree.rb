['facts', 'rules'].each do |f|
  require File.expand_path(File.join(File.dirname(__FILE__), 'family_tree', f))
end
