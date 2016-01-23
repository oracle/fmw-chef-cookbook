# Chef tests

## Chef
- optional update /vagrant/chef/node.json or /vagrant/chef/solo.rb

- sudo chef-solo --config /vagrant/chef/solo.rb --json-attributes /vagrant/chef/node.json
- sudo chef-solo --config /vagrant/chef/solo.rb --json-attributes /vagrant/chef/node.json --why-run

Windows, open cmd as administrator 
- chef-solo --config C:/projects/vagrant_chef_puppet_linux7.0/chef/solo_win.rb --json-attributes C:/projects/vagrant_chef_puppet_linux7.0/chef/node_win.json

## Ruby

- vagrant ssh
- sudo su -
- ruby -v
- gem --version
- yum install -y libxml2-devel libxslt-devel

## Bundler

- disconnect vpn
- gem install bundler --no-rdoc --no-ri
- cd /vagrant/chef/cookbooks/fmw_inst
- bundle -v
- bundle install --without development

## Test

- bundle exec foodcritic .
- bundle exec rspec
- bundle exec rubocop
- bundle exec rake yard

## Test Kitchen

- kitchen list
- kitchen create xxx

- kitchen setup xxx
- kitchen converge xxx
- kitchen verify xxx

- kitchen login xxx
- kitchen destroy xx


