# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-compute-anywhere
# Recipe:: ceilometer-cma
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

db_type = node['openstack']['db']['telemetry']['service_type']
node.default['openstack']['db']['python_packages'].delete(db_type)
node.force_override['openstack']['db']['python_packages'][db_type] = [] # :pragma-foodcritic: ~FC019
node.default['openstack']['telemetry']['platform'].delete('common_packages')
node.force_override['openstack']['telemetry']['platform']['common_packages'] = [] # :pragma-foodcritic: ~FC019
node.default['openstack']['telemetry'].delete('hypervisor_inspector')
node.force_override['openstack']['telemetry']['hypervisor_inspector'] = 'zvm' # :pragma-foodcritic: ~FC019

telemetry_conf_dir = node['openstack']['telemetry']['conf_dir']
telemetry_conf_template = node['openstack']['telemetry']['conf']

include_recipe 'openstack-telemetry::common'

run_context.resource_collection.each do |r|
  r.action(:nothing) if r.to_s == "directory[#{telemetry_conf_dir}]"
  r.action(:nothing) if r.to_s == "template[#{telemetry_conf_template}]"
end

parent_variables = run_context.resource_collection.find("template[#{telemetry_conf_template}]").variables

template telemetry_conf_template do
  source 'ceilometer_zvm.conf.erb'
  owner node['openstack']['telemetry']['user']
  group node['openstack']['telemetry']['group']
  mode 00640

  variables(
    parent_variables
  )
end

service 'ceilometer-agent-compute' do
  service_name 'openstack-ceilometer-polling'
  supports status: true, restart: true
  subscribes :restart, "template[#{node['openstack']['telemetry']['conf']}]"

  action [:start]
end
