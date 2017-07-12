property :name, kind_of: String, name_property: true
property :sql_fqdn, kind_of: String, required: true
property :configdb, kind_of: String, required: true, default: 'SP_Config'
property :passphrase, kind_of: String, required: true
property :farm_acct, kind_of: String, required: true
property :farm_pswd, kind_of: String, required: true
property :setup_acct, kind_of: String, required: true
property :setup_pswd, kind_of: String, required: true
property :admin_db, kind_of: String, default: 'SP_Admin'
property :run_central_admin, kind_of: [TrueClass, FalseClass], default: true
property :central_admin_port, kind_of: Integer, default: 5000
property :central_admin_auth, kind_of: String, default: 'NTLM'

default_action :create

def load_current_resource
  @current_resource = Chef::Resource::SharepointInstall.new(@new_resource.name)
end

def whyrun_supported?
  true
end

action :create do
  dsc_resource 'CreateSPFarm' do
    resource :SPFarm
    property :Ensure, 'Present'
    property :DatabaseServer, new_resource.sql_fqdn
    property :FarmConfigDatabaseName, new_resource.configdb
    property :Passphrase, ps_credential(new_resource.passphrase)
    property :FarmAccount, ps_credential(new_resource.farm_acct, new_resource.farm_pswd)
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    property :AdminContentDatabaseName, new_resource.admin_db if new_resource.run_central_admin
    property :RunCentralAdmin, new_resource.run_central_admin
    property :CentralAdministrationPort, new_resource.central_admin_port if new_resource.run_central_admin
    property :CentralAdministrationAuth, new_resource.central_admin_auth if new_resource.run_central_admin
    timeout 1500
  end
end

action :join do
  dsc_resource 'JoinSPFarm' do
    resource :SPJoinFarm
    property :Ensure, 'Present'
    property :DatabaseServer, new_resource.sql_fqdn
    property :FarmConfigDatabaseName, new_resource.configdb
    property :Passphrase, ps_credential(new_resource.passphrase)
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    property :AdminContentDatabaseName, new_resource.admin_db if new_resource.run_central_admin
    property :RunCentralAdmin, new_resource.run_central_admin
  end
end
