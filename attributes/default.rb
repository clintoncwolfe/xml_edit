
if platform?('omnios') then
  default['xml_edit']['xml_binary_path'] = '/opt/omni/bin/xml'
else
  default['xml_edit']['xml_binary_path'] = '/usr/bin/xmlstarlet'
end

