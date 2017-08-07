property :name, kind_of: String, name_property: true
property :setup_acct, kind_of: String, required: true
property :setup_pswd, kind_of: String, required: true
property :desc, kind_of: String
property :realm, kind_of: String
property :sign_in_url, kind_of: String
property :identifier_claim, kind_of: String
property :claims_mapping, kind_of: Array
property :cert_thumb_print, kind_of: String
property :cert_path, kind_of: String
property :provider_name, kind_of: String
property :provider_signout_uri, kind_of: String

default_action :create_issuer

def load_current_resource
  @current_resource = Chef::Resource::SharepointTrust.new(@new_resource.name)
end

def whyrun_supported?
  true
end

action :create_issuer do
  dsc_resource 'SPTrustIssuer' do
    resource :SPTrustedIdentityTokenIssuer
    property :Ensure, 'Present'
    property :Name, new_resource.name
    property :Description, new_resource.desc
    property :Realm, new_resource.realm
    property :SignInUrl, new_resource.sign_in_url
    property :IdentifierClaim, new_resource.identifier_claim
    property :ClaimsMapping, cim_instance_array_helper(new_resource.claims_mapping)
    property :SigningCertificationThumbPrint, new_resource.cert_thumb_print if new_resource.cert_thumb_print
    property :SigningCertificateFilePath, new_resource.cert_path if new_resource.cert_path
    property :ClaimProviderName, new_resource.provider_name
    property :ProviderSignOutUri, new_resource.provider_signout_uri
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
end

action :create_root do
  dsc_resource 'NewTrustedRootAuthority' do
    resource :SPTrustedRootAuthority
    property :Ensure, 'Present'
    property :Name, new_resource.name
    property :CertificateThumbPrint, new_resource.cert_thumb_print
    property :PsDscRunAsCredential, ps_credential(new_resource.setup_acct, new_resource.setup_pswd)
  end
end
