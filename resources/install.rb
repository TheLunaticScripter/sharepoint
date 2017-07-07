property :name, kind_of: String, name_property: true
property :install_path, kind_of: String, required: true

default_action :install

def load_current_resource
  @current_resource = Chef::Resource::SharepointInstall.new(@new_resource.name)
end

def whyrun_supported?
  true
end

action :install do
  if exists?
    @new_resource.updated_by_last_action(false)
  else
    include_recipe 'powershell::powershell5'

    powershell_script 'Install NuGet Package Provider' do
      command 'Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force'
      guard_interpreter :powershell_script
      not_if '(Get-PackageProvider -Name NuGet) -ne $null'
    end

    powershell_script 'Install SharePointDSC Module' do
      command 'Install-Module SharePointDSC -Confirm:$true'
      guard_interpreter :powershell_script
      not_if ::File.exist?('C:\\Program Files\\WindowsPowerShell\\Modules\\SharePointDSC\\1.7.0.0').to_s
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
      property :InstallerPath, "#{install_path}\\prerequisiteinstaller.exe"
      property :OnlineMode, true
      timeout 1500
      reboot_action :reboot_now
    end
  end
end
