# encoding: UTF-8
#
# Cookbook Name:: openstack-zvm-compute-anywhere
# Recipe:: compute-cma
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

describe 'openstack-zvm-compute-anywhere::compute-cma' do
  describe 'redhat' do
    include_context 'compute_common_stubs'
    include_context 'zvm_driver_compute_stubs'
    let(:runner) { ChefSpec::ServerRunner.new(REDHAT_OPTS) }
    let(:node) { runner.node }
    let(:chef_run) do
      shellout = double
      cmd = double
      cho = double
      allow(Mixlib::ShellOut).to receive(:new).and_return(shellout)
      allow(shellout).to receive(:run_command).and_return(cmd)
      allow(cmd).to receive(:stdout).and_return(cho)
      allow(cho).to receive(:chomp).and_return('~nova')
      node.set['ibm-openstack']['zvm-appliance']['unchangeable-confs']['nova-conf']['default']['host'] = 'host'
      node.set['ibm-openstack']['zvm-appliance']['unchangeable-confs']['nova-conf']['default']['zvm_diskpool_type'] = 'ECKD'
      node.set['ibm-openstack']['zvm-driver']['config']['ram_allocation_ratio'] = 10
      node.set['ibm-openstack']['zvm-appliance']['unchangeable-confs']['mnadmin_user'] = 'mnadmin'
      runner.converge(described_recipe)
    end

    it 'check nova conf' do
      expect(chef_run).to create_template('/etc/nova/nova.conf').with(
        owner: 'nova',
        group: 'nova',
        mode: 00640
      )
      expect(chef_run).to render_file('/etc/nova/nova.conf').with_content('compute_driver=nova.virt.zvm.ZVMDriver')
      expect(chef_run).to render_file('/etc/nova/nova.conf').with_content('ram_allocation_ratio=10')
      expect(chef_run).to render_file('/etc/nova/nova.conf').with_content('zvm_diskpool_type=ECKD')
      expect(chef_run).to render_file('/etc/nova/nova.conf').with_content('config_drive_format=iso9660')
      expect(chef_run).to render_file('/etc/nova/nova.conf').with_content('host=host')
      expect(chef_run).to render_file('/etc/nova/nova.conf').with_content('admin_password = nova')
    end

    it 'includes openstack-common::openrc recipe' do
      expect(chef_run).to include_recipe('openstack-common::openrc')
    end

    it 'enables or starts nova-compute on boot' do
      expect(chef_run).to enable_service('openstack-nova-compute')
      expect(chef_run).to start_service('openstack-nova-compute')
    end

    it 'openrc force_override attributes' do
      expect(chef_run.node['openstack']['openrc']['path']).to eq('/home/mnadmin')
      expect(chef_run.node['openstack']['openrc']['file']).to eq('openrc')
      expect(chef_run.node['openstack']['openrc']['user']).to eq('mnadmin')
      expect(chef_run.node['openstack']['openrc']['group']).to eq('root')
      expect(chef_run.node['openstack']['openrc']['file_mode']).to eq('0600')
      expect(chef_run.node['openstack']['openrc']['path_mode']).to eq('0755')
    end

  end
end
