# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-compute-anywhere
# Recipe:: network-cma
#
# Copyright 2015, 2016 IBM Corp.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

db_type = node['openstack']['db']['network']['service_type']
node.default['openstack']['db']['python_packages'].delete(db_type)
node.force_override['openstack']['db']['python_packages'][db_type] = [] # :pragma-foodcritic: ~FC019
%w{nova_network_packages neutron_packages neutron_lb_packages neutron_vpn_packages neutron_client_packages}.each do |attr|
  node.default['openstack']['network']['platform'].delete(attr)
  node.force_override['openstack']['network']['platform'][attr] = [] # :pragma-foodcritic: ~FC019
end
node.default['openstack']['identity']['platform'].delete('keystone_client_packages')
node.force_override['openstack']['identity']['platform']['keystone_client_packages'] = [] # :pragma-foodcritic: ~FC019

include_recipe 'openstack-network::default'

run_context.resource_collection.each do |r|
  r.action(:nothing) if r.to_s == 'directory[/etc/neutron/plugins]'
  r.action(:nothing) if r.to_s == 'directory[/var/cache/neutron]'
  r.action(:nothing) if r.to_s == 'template[/etc/neutron/rootwrap.conf]'
  r.action(:nothing) if r.to_s == 'service[neutron-server]'
  r.action(:nothing) if r.to_s == 'directory[/etc/neutron/plugins/ml2]'
  r.action(:nothing) if r.to_s == 'template[/etc/neutron/plugins/ml2/ml2_conf.ini]'
  r.action(:nothing) if r.to_s == 'link[/etc/neutron/plugin.ini]'
  r.action(:nothing) if r.to_s == 'template[/etc/default/neutron-server]'
end

service 'neutron-zvm-agent' do
  supports status: true, restart: true
  action [:start]
  subscribes :restart, 'template[/etc/neutron/neutron.conf]', :delayed
end
