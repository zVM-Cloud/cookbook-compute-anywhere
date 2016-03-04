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

require_relative 'spec_helper'

describe 'openstack-zvm-compute-anywhere::ceilometer-cma' do
  describe 'redhat' do
    include_context 'zvm_driver_ceilometer_stubs'
    let(:runner) { ChefSpec::ServerRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      node.set['ibm-openstack']['zvm-appliance']['unchangeable-confs']['xcat_zhcp_nodename'] = 'zhcp'
      node.set['ibm-openstack']['zvm-appliance']['unchangeable-confs']['nova-conf']['default']['zvm_xcat_password'] = 'pass'
      runner.converge(described_recipe)
    end

    it 'check ceilometer conf' do
      expect(chef_run).to create_template('/etc/ceilometer/ceilometer.conf').with(
        owner: 'ceilometer',
        group: 'ceilometer',
        mode: 00640
      )
      expect(chef_run).to render_file('/etc/ceilometer/ceilometer.conf').with_content('xcat_zhcp_nodename=zhcp')
      expect(chef_run).to render_file('/etc/ceilometer/ceilometer.conf').with_content('zvm_xcat_password=pass')
      expect(chef_run).to render_file('/etc/ceilometer/ceilometer.conf').with_content('cache_update_interval=600')
      expect(chef_run).to render_file('/etc/ceilometer/ceilometer.conf').with_content('zvm_xcat_username=admin')
      expect(chef_run).to render_file('/etc/ceilometer/ceilometer.conf').with_content('os_password = ceilometer')
      expect(chef_run).to render_file('/etc/ceilometer/ceilometer.conf').with_content('hypervisor_inspector = zvm')
    end

    it 'enables or starts openstack-ceilometer-polling' do
      expect(chef_run).to enable_service('openstack-ceilometer-polling')
      expect(chef_run).to start_service('openstack-ceilometer-polling')
    end

  end
end
