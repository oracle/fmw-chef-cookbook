#
# Cookbook Name:: fmw_jdk
# Resource:: jdk
#
# Copyright 2015 Oracle. All Rights Reserved
#
provides :fmw_jdk_jdk, os: 'linux' do |node|
  node['fmw_jdk']['install_type'] == 'tar.gz'
end

# Installs an Oracle JDK 7 or 8 on a Linux host
actions :install

# Make create the default action
default_action :install

# Java home folder, this is the folder where the jdk will be installed
attribute :java_home_dir, kind_of: String, required: true, name_attribute: true
# Linux JDK source file, it should be a file with .tar.gz as extension.
attribute :source_file,   kind_of: String, required: true, callbacks:
          {
            'source should have a valid JDK extension' => ->(extensions) { Chef::Resource::FmwJdkJdkLinux.validate_source_file(extensions) }
          }

state_attrs :java_home_dir

attr_accessor :exists

VALID_JDK_EXTENSIONS =
  ['.tar.gz']

private

def self.validate_source_file(extensions)
  VALID_JDK_EXTENSIONS.any? { |word| extensions.end_with?(word) }
end
