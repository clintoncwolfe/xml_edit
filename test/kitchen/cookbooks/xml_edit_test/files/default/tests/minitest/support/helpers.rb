module Helpers
  module XmlEdit
    include MiniTest::Chef::Resources
    include MiniTest::Chef::Context
    include MiniTest::Chef::Assertions

    #def apache_config_parses?
    #  %x{#{node['apache']['binary']} -t}
    #  $?.success?
    #end

    #def xpath_count(xpath, file)
      
    #end

  end
end
