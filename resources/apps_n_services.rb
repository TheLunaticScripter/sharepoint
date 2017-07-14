resource_name :sp_app_svc

property :name, kind_of: String, name_property: true
property :setup_acct, kind_of: String, required: true
property :setup_pswd, kind_of: String, required: true
property :svc_pool_acct, kind_of: String, required: true
property :svc_pool_pswd, kind_of: String, required: true
property :log_path, kind_of: String, default: 'C:\\SPLogs'
property :db_name, kind_of: String
property :sql_server, kind_of: String
property :usage_log_dir, kind_of: String, default: 'C:\\UsageLogs'
property :dist_cache_sizemb, kind_of: Integer, default: 1024
property :dist_cache_firewall_rule, kind_of: [TrueClass, FalseClass], default: false
property :cache_provision_order, kind_of: Array
property :app_pool_name, kind_of: String, default: 'SharePoint Service Applications'
property :my_site_url, kind_of: String
property :profile_db_name, kind_of: String
property :social_db_name, kind_of: String
property :sync_db_name, kind_of: String
property :enable_netbios, kind_of: [TrueClass, FalseClass], default: false
property :farm_acct, kind_of: String, required: true
property :farm_pswd, kind_of: String, required: true
property :audit_enable, kind_of: [TrueClass, FalseClass], default: true
property :audit_log_size, kind_of: Integer, default: 30

default_action :create_app

def load_current_resource
  @current_resource = Chef::Resource::SharepointAppsNServices.new(@new_resource.name)
end

def whyrun_supported?
  true
end

action :create_app do
  dsc_resource 'ServicePoolManagedAccount' do
    resource :SPManagedAccount
    property :Ensure, 'Present'
    property :AccountName, new_resource.svc_pool_acct
    property :Account, ps_credential(new_resource.svc_pool_acct, new_resource.svc_pool_pswd)
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
  dsc_resource 'ServiceAppPool' do
    resource :SPServiceAppPool
    property :Ensure, 'Present'
    property :ServiceAccount, new_resource.svc_pool_acct
    property :Name, new_resource.app_pool_name
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
  case new_resource.name
  when 'UsageApplication'
    dsc_resource 'UsageApplication' do
      resource :SPUsageApplication
      property :Ensure, 'Present'
      property :Name, 'Usage Service Application'
      property :DatabaseName, new_resource.db_name
      property :UsageLogCutTime, 5
      property :UsageLogLocation, new_resource.usage_log_dir
      property :UsageLogMaxFileSizeKB, 1024
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'StateServiceApp'
    dsc_resource 'StateServiceApp' do
      resource :SPStateServiceApp
      property :Ensure, 'Present'
      property :Name, 'State Service Application'
      property :DatabaseName, new_resource.db_name
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'AppManagementServiceApp'
    dsc_resource 'AppManagementServiceApp' do
      resource :SPAppManagementServiceApp
      property :Ensure, 'Present'
      property :Name, 'App Management Service Application'
      property :ApplicationPool, new_resource.app_pool_name
      property :DatabaseName, new_resource.db_name
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'BCSServiceApp'
    dsc_resource 'BCSServiceApp' do
      resource :SPBCSServiceApp
      property :Ensure, 'Present'
      property :Name, 'BCS Service Application'
      property :ApplicationPool, new_resource.app_pool_name
      property :DatabaseName, new_resource.db_name
      property :DatabaseServer, new_resource.sql_server
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'ExcelServiceApp'
    dsc_resource 'ExcelServiceApp' do
      resource :SPExcelServiceApp
      property :Ensure, 'Present'
      property :Name, 'Excel Services Service Application'
      property :ApplicationPool, new_resource.app_pool_name
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'ManagedMetaDataServiceApp'
    dsc_resource 'ManagedMetaDataServiceApp' do
      resource :SpManagedMetaDataServiceApp
      property :Ensure, 'Present'
      property :Name, 'Managed Metadata Service Application'
      property :ApplicationPool, new_resource.app_pool_name
      property :DatabaseName, new_resource.db_name
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'SearchServiceApp'
    dsc_resource 'SearchServiceApp' do
      resource :SPSearchServiceApp
      property :Ensure, 'Present'
      property :Name, 'Search Service Application'
      property :DatabaseName, new_resource.db_name
      property :ApplicationPool, new_resource.app_pool_name
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'SecureStoreServiceApp'
    dsc_resource 'SecureStoreServiceApp' do
      resource :SPSecureStoreServiceApp
      property :Ensure, 'Present'
      property :Name, 'Secure Store Service Application'
      property :ApplicationPool, new_resource.app_pool_name
      property :DatabaseName, new_resource.db_name
      property :AuditingEnabled, new_resource.audit_enable
      property :AuditlogMaxSize, new_resource.audit_log_size
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'SubscriptionSettingsServiceApp'
    dsc_resource 'SubscriptionSettingsServiceApp' do
      resource :SPSubscriptionSettingsServiceApp
      property :Ensure, 'Present'
      property :Name, 'Subscription Settings Service Application'
      property :DatabaseName, new_resource.db_name
      property :ApplicationPool, new_resource.app_pool_name
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'UserProfileServiceApp'
    dsc_resource 'UserProfileServiceApp' do
      resource :SPUserProfileServiceApp
      property :Ensure, 'Present'
      property :Name, 'User Profile Service Application'
      property :ApplicationPool, new_resource.app_pool_name
      property :MySiteHostLocation, new_resource.my_site_url
      property :ProfileDBName, new_resource.profile_db_name
      property :SocialDBName, new_resource.social_db_name
      property :SyncDBName, new_resource.sync_db_name
      property :EnableNetBIOS, new_resource.enable_netbios
      property :FarmAccount, ps_credential(new_resource.farm_acct, new_resource.farm_pswd)
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'VisioServiceApp'
    dsc_resource 'VisioServiceApp' do
      resource :SPVisioServiceApp
      property :Ensure, 'Present'
      property :Name, 'Visio Graphics Service Application'
      property :ApplicationPool, new_resource.app_pool_name
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'WordAutomationServiceApp'
    dsc_resource 'WordAutomationServiceApp' do
      resource :SPWordAutomationServiceApp
      property :Name, 'Word Automation Service Application'
      property :Ensure, 'Present'
      property :ApplicationPool, new_resource.app_pool_name
      property :DatabaseName, new_resource.db_name
      property :SupportedFileFormats, %w(docx doc mht rtf xml)
      property :DisableEmbeddedFonts, false
      property :MaximumMemoryUsage, 100
      property :RecycleThreshold, 100
      property :DisableBinaryFileScan, false
      property :ConversionProcesses, 8
      property :JobConversionFrequency, 15
      property :NumberOfConversionsPerProcess, 12
      property :TimeBeforeConversionIsMonitored, 5
      property :MaximumConversionAttempts, 2
      property :MaximumSyncConversionRequests, 25
      property :KeepAliveTimeout, 30
      property :MaximumConversionTime, 300
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  else
    raise "The SharePoint App that you are trying to install, #{new_resource.name} is currently not supported."
  end
end

action :create_svc do
  case new_resource.name
  when 'DistributedCacheService'
    dsc_resource 'ServicePoolManagedAccount' do
      resource :SPManagedAccount
      property :Ensure, 'Present'
      property :AccountName, new_resource.svc_pool_acct
      property :Account, ps_credential(new_resource.svc_pool_acct, new_resource.svc_pool_pswd)
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
    dsc_resource 'DistributedCacheService' do
      resource :SPDistributedCacheService
      property :Ensure, 'Present'
      property :Name, 'AppFabricCachingService'
      property :CacheSizeInMB, new_resource.dist_cache_sizemb
      property :ServiceAccount, new_resource.svc_pool_acct
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
      property :CreateFirewallRules, new_resource.dist_cache_firewall_rule
      property :ServerProvisionOrder, new_resource.cache_provision_order if new_resource.cache_provision_order
    end
  when 'BCSServiceInstance'
    dsc_resource 'BCSServiceInstance' do
      resource :SPServiceInstance
      property :Ensure, 'Present'
      property :Name, 'Business Data Connectivity Service'
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  when 'ManagedMetadataServiceInstance'
    dsc_resource 'ManagedMetadataServiceInstance' do
      resource :SPServiceInstance
      property :Ensure, 'Present'
      property :Name, 'Managed Metadata Web Service'
      property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
    end
  end
end
