property :name, kind_of: String, name_property: true
property :setup_acct, kind_of: String, required: true
property :setup_pswd, kind_of: String, required: true

default_action :create

def load_current_resource
  @current_resource = Chef::Resource::SharepointAppsNServices.new(@new_resource.name)
end

def whyrun_supported?
  true
end

action :create do
  puts 'Creates the site collection'
end