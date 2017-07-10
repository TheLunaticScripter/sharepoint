property :name, kind_of: String, name_property: true
property :new_resource.install_path, kind_of: String, required: true
property :sxs_source, kind_of: String, required: true
property :pre_req_timeout, kind_of: Integer, default: 1500
property :sp_license_key, kind_of: String

default_action :install

def load_current_resource
  @current_resource = Chef::Resource::SharepointInstall.new(@new_resource.name)
end

def whyrun_supported?
  true
end

action :install do
  include_recipe 'powershell::powershell5'

  powershell_script 'Install NuGet Package Provider' do
    code 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force'
    guard_interpreter :powershell_script
    not_if '(Get-PackageProvider -Name NuGet) -ne $null'
  end
  powershell_script 'Install SharePointDSC Module' do
    code 'Install-Module SharePointDSC -Confirm:$true'
    guard_interpreter :powershell_script
    not_if ::File.exist?('C:\\Program Files\\WindowsPowerShell\\Modules\\SharePointDSC').to_s
  end

  # Set up LCM
  powershell_script 'Configure the LCM' do
    code <<-EOH
      Configuration ConfigLCM
      {
        Node "localhost"
        {
            LocalConfigurationManager
            {
              ConfigurationMode = "ApplyOnly"
              RebootNodeIfNeeded = $true
              RefreshMode = "Disabled"
            }
        }
      }
      ConfigLCM -OutputPath "#{Chef::Config[:file_cache_path]}\\DSC_LCM"
      Set-DscLocalConfigurationManager -Path "#{Chef::Config[:file_cache_path]}\\DSC_LCM"
    EOH
    not_if '(Get-DscLocalConfigurationManager | select -ExpandProperty "RefreshMode") -eq "Disabled"'
  end
  dsc_resource 'InstallPrereqs' do
    resource :SPInstallPrereqs
    property :Ensure, 'Present'
    property :SXSpath, sxs_source
    property :InstallerPath, "#{new_resource.install_path}\\prerequisiteinstaller.exe"
    property :SQLNCli, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\sqlncli.msi"
    property :PowerShell, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\Windows6.1-KB2506143-x64.msu"
    property :NETFX, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\dotNetFx45_Full_x86_x64.exe"
    property :IDFX, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\Windows6.1-KB974405-x64.msu"
    property :Sync, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\Synchronization.msi"
    property :AppFabric, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\WindowsServerAppFabricSetup_x64.exe"
    property :IDFX11, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\MicrosoftIdentityExtensions-64.msi"
    property :MSIPCClient, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\setup_msipc_x64.msi"
    property :WCFDataServices, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\WcfDataServices.exe"
    property :KB2671763, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\AppFabric1.1-RTM-KB2671763-x64-ENU.exe"
    property :WCFDataServices56, "#{new_resource.install_path}\\prerequisiteinstallerfiles\\WcfDataServices56.exe"
    property :OnlineMode, false
    timeout new_resource.pre_req_timeout
    reboot_action :reboot_now
  end
  dsc_resource 'InstallSharePoint' do
    resource :SPInstall
    property :Ensure, 'Present'
    property :BinaryDir, new_resource.install_path
    property :ProductKey, new_resource.sp_license_key
  end
end
