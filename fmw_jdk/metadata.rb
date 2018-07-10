name             'fmw_jdk'
maintainer       'Oracle'
maintainer_email 'fmw-chef-and-puppet_ww@oracle.com'
license          'MIT'
description      'Installs Oracle JDK 7,8 on any Windows, Linux or Solaris host'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.5'

recipe            "fmw_jdk",
                  "This is an empty recipe and does not do anything"
recipe            "fmw_jdk::install",
                  "This will install the JDK on a host"
recipe            "fmw_jdk::rng_service",
                  "This will install and configure the rng package on any RedHat or Debian family linux distribution"

%w{ windows solaris debian ubuntu redhat centos oracle sles }.each do |os|
  supports os
end