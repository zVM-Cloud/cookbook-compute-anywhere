# encoding: UTF-8
#
# =================================================================
# Licensed Materials - Property of IBM
#
# Copyright 2015, 2016 IBM Corp.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
# =================================================================
#
# Cookbook Name:: openstack-zvm-compute-anywhere
# Recipe:: compute-cma
#

# generate openrc file
mnadmin = node['ibm-openstack']['zvm-appliance']['unchangeable-confs']['mnadmin_user']
node.force_override['openstack']['openrc']['path'] = "/home/#{mnadmin}" # :pragma-foodcritic: ~FC019
node.force_override['openstack']['openrc']['file'] = 'openrc' # :pragma-foodcritic: ~FC019
node.force_override['openstack']['openrc']['user'] = mnadmin # :pragma-foodcritic: ~FC019
node.force_override['openstack']['openrc']['group'] = 'root' # :pragma-foodcritic: ~FC019
node.force_override['openstack']['openrc']['file_mode'] = '0600' # :pragma-foodcritic: ~FC019
node.force_override['openstack']['openrc']['path_mode'] = '0755' # :pragma-foodcritic: ~FC019
include_recipe 'openstack-common::openrc'

node.default['openstack']['compute']['platform'].delete('common_packages')
node.force_override['openstack']['compute']['platform']['common_packages'] = [] # :pragma-foodcritic: ~FC019
db_type = node['openstack']['db']['compute']['service_type']
node.default['openstack']['db']['python_packages'].delete(db_type)
node.force_override['openstack']['db']['python_packages'][db_type] = [] # :pragma-foodcritic: ~FC019
node.default['openstack']['compute']['platform'].delete('memcache_python_packages')
node.force_override['openstack']['compute']['platform']['memcache_python_packages'] = [] # :pragma-foodcritic: ~FC019

state_path = node['openstack']['compute']['state_path']
lock_path = node['openstack']['compute']['lock_path']

include_recipe 'openstack-compute::nova-common'

run_context.resource_collection.each do |r|
  r.action(:nothing) if r.to_s == "directory[/etc/nova]"
  r.action(:nothing) if r.to_s == "directory[#{state_path}]"
  r.action(:nothing) if r.to_s == "directory[#{lock_path}]"
  r.action(:nothing) if r.to_s == "template[/etc/nova/nova.conf]}]"
  r.action(:nothing) if r.to_s == "template[/etc/nova/rootwrap.conf]}]"
  r.action(:nothing) if r.to_s == "execute[enable nova login]"
end

parent_variables = run_context.resource_collection.find("template[/etc/nova/nova.conf]").variables

node.default['openstack']['compute'].delete('driver')
node.default['openstack']['compute']['config'].delete('force_config_drive')
node.default['openstack']['compute']['config'].delete('config_drive_format')
node.default['openstack']['compute']['config'].delete('ram_allocation_ratio')
node.default['openstack']['compute'].delete('rpc_response_timeout')
node.force_override['openstack']['compute']['driver'] = 'nova.virt.zvm.ZVMDriver' # :pragma-foodcritic: ~FC019
node.force_override['openstack']['compute']['config']['force_config_drive'] = true # :pragma-foodcritic: ~FC019
node.force_override['openstack']['compute']['config']['config_drive_format'] = 'iso9660' # :pragma-foodcritic: ~FC019
node.force_override['openstack']['compute']['config']['ram_allocation_ratio'] = node['ibm-openstack']['zvm-driver']['config']['ram_allocation_ratio'] # :pragma-foodcritic: ~FC019
node.force_override['openstack']['compute']['rpc_response_timeout'] = node['ibm-openstack']['zvm-driver']['rpc_response_timeout'] # :pragma-foodcritic: ~FC019

template '/etc/nova/nova.conf' do
  source 'nova_zvm.conf.erb'
  owner node['openstack']['compute']['user']
  group node['openstack']['compute']['group']
  mode 00640

  variables(
    parent_variables
  )
end

compute_service = node['openstack']['compute']['platform']['compute_compute_service']

service compute_service do
  supports status: true, restart: true
  provider Chef::Provider::Service::Init::Redhat
  subscribes :restart, resources('template[/etc/nova/nova.conf]')

  action [:start]
end
