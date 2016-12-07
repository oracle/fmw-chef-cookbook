name             'fmw_wls'
maintainer       'Oracle'
maintainer_email 'fmw-chef-and-puppet_ww@oracle.com'
license          'MIT'
description      'Installs Oracle WebLogic 11g, 12c on any Windows, Linux or Solaris host'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.3'

recipe            "fmw_wls",
                  "This is an empty recipe and does not do anything"
recipe            "fmw_wls::install",
                  "This will install WebLogic on a host"
recipe            "fmw_wls::setup",
                  "Optional creates the WebLogic operating user and group on a any linux or solaris host"

depends          'fmw_jdk'

%w{ windows solaris debian ubuntu redhat centos oracle sles }.each do |os|
  supports os
end