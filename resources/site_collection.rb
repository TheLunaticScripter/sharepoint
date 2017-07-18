property :name, kind_of: String, name_property: true
property :setup_acct, kind_of: String, required: true
property :setup_pswd, kind_of: String, required: true
property :url, kind_of: String, required: true
property :owner, kind_of: String, required: true
property :host_web_app, kind_of: String
property :template, kind_of: String, default: 'STS#0'
property :db_name, kind_of: String

default_action :create

def load_current_resource
  @current_resource = Chef::Resource::SharepointSiteCollection.new(@new_resource.name)
end

def whyrun_supported?
  true
end

action :create do
  dsc_resource new_resource.name do
    resource :SPSite
    property :Url, new_resource.url
    property :OwnerAlias, new_resource.owner
    property :HostHeaderWebApplication, new_resource.host_web_app
    property :Name, new_resource.name
    property :Template, new_resource.template
    property :ContentDatabase, new_resource.db_name if new_resource.db_name
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
end
