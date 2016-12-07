name             'fmw_bsu'
maintainer       'Oracle'
maintainer_email 'fmw-chef-and-puppet_ww@oracle.com'
license          'MIT'
description      'Patch Oracle WebLogic 10.3.6 or 12.1.1'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.3'

recipe            "fmw_bsu",
                  "This is an empty recipe and does not do anything"
recipe            "fmw_bsu::weblogic",
                  "This will install the 10.3.6 or 12.1.1 WebLogic BSU patch"

depends          'fmw_wls'

%w{ windows solaris debian ubuntu redhat centos oracle sles }.each do |os|
  supports os
end

