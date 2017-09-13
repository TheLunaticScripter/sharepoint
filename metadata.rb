name 'sharepoint'
maintainer 'John Snow'
maintainer_email 'thelunaticscripter@outlook.com'
license 'All Rights Reserved'
description 'Installs/Configures sharepoint'
long_description 'Installs/Configures sharepoint'
version '2.0.5'
chef_version '>= 12.1' if respond_to?(:chef_version)

depends 'powershell'
depends 'dsc_contrib', '>= 0.6.0'

# The `issues_url` points to the location where issues for this cookbook are
# tracked.  A `View Issues` link will be displayed on this cookbook's page when
# uploaded to a Supermarket.
#
# issues_url 'https://github.com/<insert_org_here>/sharepoint/issues'

# The `source_url` points to the development repository for this cookbook.  A
# `View Source` link will be displayed on this cookbook's page when uploaded to
# a Supermarket.
#
# source_url 'https://github.com/<insert_org_here>/sharepoint'
