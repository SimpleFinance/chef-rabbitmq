# providers/default.rb
#
# Author: Simple Finance <ops@simple.com>
# License: Apache License, Version 2.0
#
# Copyright 2013 Simple Finance Technology Corporation
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
# Manages a RabbitMQ installation

def initialize(new_resource, run_context)
  super
  @nodename   = new_resource.nodename
  @user       = new_resource.user
  @version    = new_resource.version
  @checksum   = new_resource.checksum
  @cookie_str = new_resource.cookie
  @dep_gems   = rabbitmq_dependency_gems
  @source_pkg = rabbitmq_source_package('rabbitmq.deb')
  @installer  = rabbitmq_install_manager('rabbitmq')
  @service    = rabbitmq_service('rabbitmq-server')
  @logdir     = rabbitmq_directory_resource('/var/log/rabbitmq')
  @mnesiadir  = rabbitmq_directory_resource('/var/lib/rabbitmq/mnesia')
  @cookie     = rabbitmq_file_resource('/var/lib/rabbitmq/.erlang.cookie')
  @reset      = rabbitmq_execute_resource('reset rabbitmq')
  @plugins    = rabbitmq_execute_resource('install plugins')
end

# TODO: Un-hardcode paths
action :install do
  # Install the rabbitmq_http_api_client and amqp gems
  @dep_gems.each do |gem, version|
    gem_resource = Chef::Resource::ChefGem.new(gem, @run_context)
    gem_resource.version(version)
    gem_resource.run_action(:install)
  end

  @source_pkg.source("https://www.rabbitmq.com/releases/rabbitmq-server/v#{@version}/rabbitmq-server_#{@version}-1_all.deb")
  @source_pkg.path("#{Chef::Config[:file_cache_path]}/rabbitmq-#{@version}.deb")
  @source_pkg.checksum(@checksum)
  @source_pkg.run_action(:create)

  @installer.source("#{Chef::Config[:file_cache_path]}/rabbitmq-#{@version}.deb")
  @installer.provider(Chef::Provider::Package::Dpkg)
  @installer.run_action(:install)

  # Give RabbitMQ a place to log to
  @logdir.path('/var/log/rabbitmq')
  @logdir.owner(@user)
  @logdir.group(@user)
  @logdir.mode(00700)
  @logdir.recursive(true)
  @logdir.run_action(:create)

  # Directory for mnesia data
  @mnesiadir.path('/var/lib/rabbitmq/mnesia')
  @mnesiadir.owner(@user)
  @mnesiadir.group(@user)
  @mnesiadir.mode(00700)
  @mnesiadir.recursive(true)
  @mnesiadir.run_action(:create)

  # Install the management plugin
  @plugins.command('rabbitmq-plugins enable rabbitmq_management')
  @plugins.user('root')
  @plugins.run_action(:run)

  # An erlang cookie is necessary for clustering
  # The process for changing the Erlang cookie is to stop the Erlang node,
  # render out the new cookie, start the Erlang node, then reset the RabbitMQ
  # application.
  if cookie_should_be_rendered?
    @service.provider(Chef::Provider::Service::Init)
    @service.run_action(:stop)

    @cookie.path(cookie_path)
    @cookie.content(@cookie_str)
    @cookie.owner(@user)
    @cookie.group(@user)
    @cookie.mode(00400)
    @cookie.run_action(:create)

    @service.run_action(:start)

    # This picks up the new Erlang cookie value.
    @reset.command('rabbitmqctl stop_app && rabbitmqctl reset && rabbitmqctl start_app')
    @reset.user('root')
    @reset.run_action(:run)
  end

  # A bit ugly, but works.
  new_resource.updated_by_last_action(
    @source_pkg.updated_by_last_action? ||
    @installer.updated_by_last_action?  ||
    @service.updated_by_last_action?    ||
    @logdir.updated_by_last_action?     ||
    @mnesiadir.updated_by_last_action?  ||
    @cookie.updated_by_last_action? )
end

action :remove do
  Chef::Log.error('Unimplemented method :remove for rabbitmq resource')
  new_resource.updated_by_last_action(false)
end

private

def rabbitmq_execute_resource(cmd='')
  return Chef::Resource::Execute.new(cmd, @run_context)
end

def rabbitmq_file_resource(path='')
  return Chef::Resource::File.new(path, @run_context)
end

def rabbitmq_directory_resource(path='')
  return Chef::Resource::Directory.new(path, @run_context)
end

def rabbitmq_source_package(path='')
  return Chef::Resource::RemoteFile.new(path, @run_context)
end

def rabbitmq_install_manager(pkg='')
  return Chef::Resource::Package.new(pkg, @run_context)
end

def rabbitmq_service(name='')
  return Chef::Resource::Service.new(name, @run_context)
end

# Ensure you always return an array here, so we can add dependencies easily.
def rabbitmq_dependency_gems
  return {'rabbitmq_http_api_client' => '1.3.0'}
end

def cookie_path
  return '/var/lib/rabbitmq/.erlang.cookie'
end

def cookie_should_be_rendered?
  if @cookie_str.nil?
    return false
  else
    return !::File.exist?(cookie_path) || ::File.read(cookie_path) != @cookie_str
  end
end
