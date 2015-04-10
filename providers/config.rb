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

  if @kernel || @rabbit
    @config.path('/etc/rabbitmq/rabbitmq.config')
    @config.content(render_config(@kernel, @rabbit))
    @config.owner('rabbitmq')
    @config.group('rabbitmq')
    @config.mode(00400)
    @config.run_action(:create)
  end

  if @env
    @envconf.path('/etc/rabbitmq/rabbitmq-env.conf')
    @envconf.content(render_env_config(@env))
    @envconf.owner('rabbitmq')
    @envconf.group('rabbitmq')
    @envconf.mode(00400)
    @envconf.run_action(:create)
  end

  if requires_restart?
    @service.run_action(:restart)
  else
    @service.run_action(:nothing)
  end

  new_resource.updated_by_last_action(
    @envconf.updated_by_last_action? || @config.updated_by_last_action? )
end

action :delete do
  Chef::Log.error('Unimplemented method :delete for rabbitmq_config')
  new_resource.updated_by_last_action(false)
end

private

def render_config(kernel_params, rabbit_params)
  params = []
  if @kernel
    kernel = render_erlang_parameters('kernel', kernel_params)
    params << kernel
  end
  if @rabbit
    rabbit = render_erlang_parameters('rabbit', rabbit_params)
    params << rabbit
  end
  return "[\n#{params.join(",\n")}\n].\n"
end

def render_env_config(env)
  if env
    return env.collect{|k,v| "#{k}=#{v}"}.join("\n")
  end
end

def render_erlang_parameters(name, hash={})
  strs = hash.collect do |k,v|
    str = "    {#{k}, "
    if v.is_a?(Hash)
      str << "[\n"
      buffer = " "*(8 + k.length)
      str << v.collect{|p,n| "#{buffer}{#{p}, #{n}}"}.join(",\n")
      str << "]}"
    else
      str << v.to_s
      str << "}"
    end
  end
  return "  {#{name}, [\n#{strs.join(",\n")}\n  ]}"
end

def rabbitmq_file_resource(path='')
  return Chef::Resource::File.new(path, @run_context)
end

def rabbitmq_service_handle(name='rabbitmq-server')
  return Chef::Resource::Service.new(name, @run_context)
end

# Restarts RabbitMQ if either of the environment config or the general config
# have changed.
def requires_restart?
  return @config.updated_by_last_action? || @envconf.updated_by_last_action?
end
