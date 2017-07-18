property :name, kind_of: String, name_property: true
property :web_app_acct, kind_of: String, required: true
property :web_app_pswd, kind_of: String, required: true
property :setup_acct, kind_of: String, required: true
property :setup_pswd, kind_of: String, required: true
property :app_pool, kind_of: String, required: true
property :farm_acct, kind_of: String
property :farm_pswd, kind_of: String
property :db_name, kind_of: String, default: 'SP_Content'
property :auth_method, kind_of: String, default: 'NTLM'
property :auth_provider, kind_of: String
property :url, kind_of: String, required: true
property :new_url, kind_of: String
property :port, kind_of: String, default: '80'
property :allow_anonymous, kind_of: [TrueClass, FalseClass], default: false
property :zone, kind_of: String, default: 'Intranet'
property :super_user, kind_of: String
property :super_reader, kind_of: String

default_action :create

def load_current_resource
  @current_resource = Chef::Resource::SharepointWebApp.new(@new_resource.name)
end

def whyrun_supported?
  true
end

action :create do
  dsc_resource 'WebAppManagedAccount' do
    resource :SPManagedAccount
    property :Ensure, 'Present'
    property :AccountName, new_resource.web_app_acct
    property :Account, ps_credential(new_resource.web_app_acct, new_resource.web_app_pswd)
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
  dsc_resource "SharePointWebApp#{db_name}" do
    resource :SPWebApplication
    property :Ensure, 'Present'
    property :Name, new_resource.name
    property :ApplicationPool, new_resource.app_pool
    property :ApplicationPoolAccount, new_resource.web_app_acct
    property :AllowAnonymous, new_resource.allow_anonymous
    property :AuthenticationMethod, new_resource.auth_method
    property :AuthenticationProvider, new_resource.auth_provider if new_resource.auth_method == 'Claims'
    property :DatabaseName, new_resource.db_name
    property :Url, new_resource.url
    property :Port, new_resource.port
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
end

action :add_extension do
  dsc_resource 'WebAppExtension' do
    resource :SPWebApplicationExtension
    property :Ensure, 'Present'
    property :WebAppUrl, new_resource.url
    property :Name, new_resource.name
    property :AllowAnonymous, new_resource.allow_anonymous
    property :Url, new_resource.new_url
    property :Zone, new_resource.zone
    property :AuthenticationMethod, new_resource.auth_method
    property :AuthenticationProvider, new_resource.auth_provider if new_resource.auth_method == 'Claims'
    property :Port, new_resource.port
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
end

action :add_alt_url do
  dsc_resource 'AddAlternateUrl' do
    resource :SPAlteranteUrl
    property :Ensure, 'Present'
    property :Zone, new_resource.zone
    property :WebAppUrl, new_resource.url
    property :Url, new_resource.new_url
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
end

action :create_app_catalog do
  dsc_resource 'NewAppCatalog' do
    resource :SPAppCatalog
    property :SiteUrl, new_resource.url
    property :PsDscRunAsCredential, ps_credential(new_resource.farm_acct, new_resource.farm_pswd)
  end
end

action :create_cache_accts do
  if new_resource.super_user == new_resource.super_reader
    raise 'The Super User and Super Reader cache Accounts cannot be the same user.'
  end
  dsc_resource 'WebAppCacheAccounts' do
    resource :SPCacheAccounts
    property :WebAppUrl, new_resource.url
    property :SuperUserAlias, new_resource.super_user
    property :SuperReaderAlias, new_resource.super_reader
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
end
