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

include RabbitMQ::Config

def initialize(new_resource, run_context)
  super
  @user       = new_resource.user
  @version    = new_resource.version
  @checksum   = new_resource.checksum
  @source_pkg = rabbitmq_source_package
  @installer  = rabbitmq_install_manager
  @service    = rabbitmq_service
  @logdir     = rabbitmq_directory_resource
  @mnesiadir  = rabbitmq_directory_resource
  @config     = rabbitmq_file_resource
  @cookie     = rabbitmq_file_resource
end

# TODO : Un-hardcode paths
# TODO : Multiplatform ...
action :install do

  @source_pkg.source("https://www.rabbitmq.com/releases/rabbitmq-server/v#{@version}/rabbitmq-server_#{@version}-1_all.deb")
  @source_pkg.path("#{Chef::Config[:file_cache_path]}/rabbitmq-#{@version}.deb")
  @source_pkd.checksum(@checksum)
  @source_pkg.run_action(:create)
  
  @package.provider(Chef::Provider::Package::Dpkg)
  @package.run_action(:install)

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

  # Render RabbitMQ's config file via helper library
  @config.path('/etc/rabbitmq/rabbitmq.config')
  @config.content(render_config)
  @config.owner('root')
  @config.group('root')
  @config.mode(00400)
  @config.run_action(:create)

  # Also render the environment file
  @envconf.path('/etc/rabbitmq/rabbitmq-env.conf')
  @envconf.content(render_env_config)
  @envconf.owner('root')
  @envconf.group('root')
  @envconf.mode(00400)

  # An erlang cookie is necessary for clustering
  @cookie.path('/var/lib/rabbitmq/.erlang_cookie')
  @cookie.content(render_erlang_cookie)
  @cookie.owner(@user)
  @cookie.group(@user)
  @cookie.mode(00400)
  @cookie.run_action(:create)

  # We need to restart ourselves
  # TODO : Fix, obviously broken.
  @service.provider(Chef::Provider::Service::Init)
  @service.run_action(:start)
  @service.subscribes(:restart, 'file[/etc/rabbitmq/rabbitmq-env.conf]', :delayed)
  @service.subscribes(:restart, 'file[/etc/rabbitmq/rabbitmq.config]', :delayed)
  @service.subscribes(:restart, 'file[/var/lib/rabbitmq/.erlang_cookie]', :delayed)

  # We'll always say false, since this resource is higher level and really just
  # a manager for other resources; they will specify if they were updated.
  new_resource.updated_by_last_action(false)
end

action :remove do
  Chef::Log.error('Unimplemented method :remove for rabbitmq resource')
  new_resource.updated_by_last_action(false)
end

private

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
