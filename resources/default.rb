actions :insert, :replace, :delete, :nothing

attribute :path, :kind_of => String, :required => true
attribute :cursor_xpath, :kind_of => String, :required => true
attribute :payload, :kind_of => String, :required => false
attribute :only_if_xpath, :kind_of => String, :required => false
attribute :not_if_xpath, :kind_of => String, :required => false
attribute :backups, :kind_of => Integer, :required => false, :default => 5

def initialize(*args)
  super
  @action = :insert
end
