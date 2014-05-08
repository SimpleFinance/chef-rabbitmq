# providers/config.rb
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
# Manage RabbitMQ configuration files.

def initialize(new_resource, run_context)
  super
  @nodename = new_resource.nodename
  @kernel   = new_resource.kernel
  @rabbit   = new_resource.rabbit
  @env      = new_resource.env
  @config   = rabbitmq_file_resource('rabbitmq.config')
  @envconf  = rabbitmq_file_resource('rabbitmq-env.conf')
  @service  = rabbitmq_service_handle('rabbitmq-server')
end

# Writes out rabbitmq.config and rabbitmq-env.conf
action :render do
  @service.run_action(:nothing)

  # TODO : Configurable user?
  @config.path('/etc/rabbitmq/rabbitmq.config')
  @config.content(render_config(@kernel, @rabbit))
  @config.owner('rabbitmq')
  @config.group('rabbitmq')
  @config.mode(00400)
  @config.notifies(:restart, @service, :delayed)
  @config.run_action(:create)

  @envconf.path('/etc/rabbitmq/rabbitmq-env.conf')
  @envconf.content(render_env_config(@env))
  @envconf.owner('rabbitmq')
  @envconf.group('rabbitmq')
  @envconf.mode(00400)
  @envconf.notifies(:restart, @service, :delayed)
  @envconf.run_action(:create)

  new_resource.updated_by_last_action(
    @envconf.updated_by_last_action? || @config.updated_by_last_action? )
end

action :delete do
  Chef::Log.error('Unimplemented method :delete for rabbitmq_config')
  new_resource.updated_by_last_action(false)
end

private

def render_config(kernel_params, rabbit_params)
  kernel = render_kernel_parameters(kernel_params)
  rabbit = render_rabbit_parameters(rabbit_params)
  return <<-eos
[\n#{[kernel, rabbit].join(",\n")}\n].
  eos
end

def render_env_config(env)
  if env.nil?
    env = env_defaults
  end
  return env.collect{|k,v| "#{k}=#{v}"}.join("\n")
end

def render_kernel_parameters(hash)
  if hash.nil?
    hash = kernel_defaults
  end
  return <<-eos
  {kernel, [
#{hash.collect{|k,v| "    {#{k}, #{v}}"}.join(",\n")}
  ]}
eos
end

def render_rabbit_parameters(hash)
  if hash.nil?
    hash = rabbit_defaults
  end
  return <<-eos
  {rabbit, [
#{hash.collect{|k,v| "    {#{k}, #{v}}"}.join(",\n")}
  ]}
  eos
end

def rabbitmq_file_resource(path='')
  return Chef::Resource::File.new(path, @run_context)
end

def rabbitmq_service_handle(name='rabbitmq-server')
  return Chef::Resource::Service.new(name, @run_context)
end

# See https://www.rabbitmq.com/configure.html#define-environment-variables
def env_defaults
  return {
    'NODENAME' => 'rabbit',
    'NODE_PORT' => '5671',
    'NODE_IP_ADDRESS' => '""',
    'CONFIG_FILE' => '/etc/rabbitmq/rabbitmq',
    'MNESIA_BASE' => '/var/lib/rabbitmq/mnesia',
    'LOG_BASE' => '/var/log/rabbitmq'
  }
end

# See http://www.erlang.org/doc/man/kernel_app.html
def kernel_defaults
  return {}
end

# See https://www.rabbitmq.com/configure.html#configuration-file
def rabbit_defaults
  return {
    'tcp_listeners' => '[5672]'
  }
end
