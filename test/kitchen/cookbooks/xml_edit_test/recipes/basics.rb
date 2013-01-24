package 'xmlstarlet'

test_dir = "/var/tmp/xml_edit_test"

directory test_dir

cookbook_file test_dir + '/insert-01.xml' do
  source 'short-books.xml'
end
