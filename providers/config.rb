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
# Create and delete virtualhosts

def initialize(new_resource, run_context)
  super
  @kernel  = new_resource.kernel
  @rabbit  = new_resource.rabbit
  @env     = new_resource.env
  @config  = rabbitmq_file_resource('rabbitmq.config')
  @envconf = rabbitmq_file_resource('rabbitmq-env.conf')
end

# Writes out rabbitmq.config and rabbitmq-env.conf
action :render do
  @config.path('/etc/rabbitmq/rabbitmq.config')
  @config.content(render_config(@kernel, @rabbit))
  @config.owner('root')
  @config.group('root')
  @config.mode(00400)
  @config.run_action(:create)

  @envconf.path('/etc/rabbitmq/rabbitmq-env.conf')
  @envconf.content(render_env_config(@env))
  @envconf.owner('root')
  @envconf.group('root')
  @envconf.mode(00400)
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
  return "[\n#{[kernel, rabbit].join(",\n")}\n]."
end

def render_env_config(env=env_defaults)
  return env.collect{|k,v| "#{k}=#{v}"}.join("\n")
end

def render_kernel_parameters(hash=kernel_defaults)
  formatted = hash.each_pair do |k, v|
  end
  return "{kernel,\n[#{formatted}\n]}"
end

def render_rabbit_parameters(hash=rabbit_defaults)
  formatted = []
  rendered = <<-eos
{rabbit, [
#{formatted.each{|f| f.prepend('    ').join(",\n")}}
]}
  eos
  return rendered
end

def rabbitmq_file_resource(path='')
  return Chef::Resource::File.new(path, @run_context)
end

def env_defaults
  return {}
end

def kernel_defaults
  return {}
end

def rabbit_defaults
  return {}
end
