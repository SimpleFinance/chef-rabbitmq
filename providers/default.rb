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

require 'securerandom'

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
  @cookie     = rabbitmq_file_resource('/var/lib/rabbitmq/.erlang_cookie')
end

# TODO : Un-hardcode paths
# TODO : Multiplatform ...
action :install do

  # Install the rabbitmq_http_api_client and amqp gems
  @dep_gems.each do |gem|
    gem.run_action(:install)
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

  # An erlang cookie is necessary for clustering
  @cookie.path('/var/lib/rabbitmq/.erlang_cookie')
  @cookie.content(render_erlang_cookie(@cookie_str))
  @cookie.owner(@user)
  @cookie.group(@user)
  @cookie.mode(00400)
  @cookie.run_action(:create)

  # We need to restart ourselves
  # TODO : Fix, obviously broken.
  @service.provider(Chef::Provider::Service::Init)
  @service.run_action(:start)
  @service.subscribes(:restart, 'file[/var/lib/rabbitmq/.erlang_cookie]', :delayed)

  # A bit ugly, but works.
  new_resource.updated_by_last_action(
    @dep_gems.collect do |g| 
      g.updated_by_last_action? 
    end.any?                            ||
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

def rabbitmq_dependency_gems
  amqp = Chef::Resource::ChefGem.new('amqp', @run_context)
  cli = Chef::Resource::ChefGem.new('rabbitmq_http_api_client', @run_context)
  return amqp, cli
end

# If the user provides new_resource.cookie, the cookie will be populated with
# that value. Otherwise, generate a random hexidecimal string (any alphanumeric
# string works, however).
def render_erlang_cookie(str)
  if str.nil?
    return SecureRandom.hex
  else
    return str
  end
end

# Sane default values to render into the RabbitMQ environment file.
def default_env
  return {
    'NODENAME' => @nodename
  }
end
