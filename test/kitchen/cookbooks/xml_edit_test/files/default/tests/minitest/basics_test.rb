require File.expand_path('../support/helpers', __FILE__)

test_dir = '/var/tmp/xml_edit_test/'

describe_recipe "attribute defaults" do
  include Helpers::XmlEdit
  it "should find xmlstarlet binary" do
    file(node[:xml_edit][:xml_binary_path]).must_exist
  end
end

describe_recipe "insert actions" do
  include Helpers::XmlEdit

  it "should add correct title" do
    file(test_dir + '/insert-01.xml').must_include 'The Year of The Flood'
  end
end
