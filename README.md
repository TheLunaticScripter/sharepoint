# sharepoint

Windows SharePoint Cookbook
===========================

Requirments
-----------
#### Tested Platforms
* Windows Server 2012 R2
   - Note: SharePoint 2013 has a known issue installing on a Server that has .Net 4.6 or greater

#### Chef
- Chef 12+

Usage
-----

### Purpose
This is a library cookbook with custom resoures to provide a framework for installing and configuring SharePoint

Custom Resources
----------------

### sharepoint_install
Install the SharePointDSC Module, SharePoint Pre-Req features and Software, and the SharePoint binaries

#### Actions
- 'install' - Installs SharePoint
   - Note: This install requires two reboots to successfully complete the install

#### Properties
- 'source_path' - Path to the SharePoint install binaries
   - Note: The Pre-Req install files need to be in the prerequisiteinstallerfiles folder
- 'sxs_source' - Path to the sxs source files
- 'install_dir' - Directory where Sharepoint will be installed
- 'data_dir' - Directory where SharPoint data will be stored
- 'pre_req_timeout' - Timeout for the pre-req install the default is 1500 seconds
- 'install_timeout' - Timeout for the SharePoint install the default is 600 seconds
- 'sp_license_key' - The license key for Sharepoint version that is being installed
- 'install_module - Boolean for it the SharePoinDSC module should be installed

#### Examples
Install SharePoint

```ruby
sharepoint_install 'Install SharePoint 2013' do
  source_path 'C:\\Sources\\SP2013'
  sxs_source 'C:\\Sources\\sxs'
  sp_license_key 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'
end
```

Installl SharePoint on D drive

```ruby
sharepoint_install 'Install SharePoint 2013' do
  source_path 'C:\\Sources\\SP2013'
  sxs_source 'C:\\Sources\\sxs'
  sp_license_key 'XXXXX-XXXXX-XXXXX-XXXXX-XXXXX'
  install_dir 'D:\\Program Files'
  data_dir 'D:\\SPData'
end
```

### sharepoint_farm
Create or Join a Sharepoint Farm 

#### Actions
- 'create' - Create the Farm if one doesn't exisit
- 'join' - Join a Server to the Farm

#### Properties
- 'sql_fqdn' - Full Qualified Domain Name of the SQL Server
- 'configdb' - Name of the Configuration Database
- 'passphrase' - The Farm passphrase - It is recoommended that this be secured with chef-vault or an encrypted data bag
- 'farm_acct' - The Farm account user name
- 'farm_pswd' - Password for the Farm account
- 'setup_acct' - Account used to run DSC
- 'setup_pswd' - Password for the setup account
- 'admin_db' - Database name for the Central Admin Database only required if run_central_admin is true
- 'run_central_admin' - Boolean if you want central admin installed on the node default is true
- 'central_admin_port' - Central admin port default is 5000
- 'central_admin_auth' - Authentication method for central admin, NTLM, Claims, etc. default is NTLM
- 'log_path' - Path to directory to store SharePoint Logs default is C:\SPLogs

#### Examples
Create a Farm with all the defaults

```ruby
sharepoint_farm 'Create the farm' do
  sql_fqdn 'sql.foo.local'
  passphrase 'super_secret_passphrase'
  farm_acct 'SP_Farm'
  farm_pswd 'super_secret_password123'
  setup_acct 'SP_Setup'
  setup_pswd 'super_secret_password234'
end
```

Join the Farm without central admin on the node

```ruby
sharepoint_farm 'Join the Farm' do
  sql_fqdn 'sql.foo.local'
  passphrase 'super_secret_passphrase'
  setup_acct 'SP_Setup'
  setup_pswd 'super_secretpassword234'
  run_central_admin false
end
```
