# libraries/config.rb
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
# Helpers for rendering RabbitMQ config files

module RabbitMQ
  module Config

    def render_config
      rendered = <<-eos
%%% /etc/rabbitmq/rabbitmq.config

[
#{[render_kernel_parameters, render_rabbit_parameters].join(",\n")}
].
      eos
      File.open('/etc/rabbitmq/rabbitmq.config'){|f| f.puts(rendered)}
    end

    private

    def render_kernel_parameters
      rendered = <<-eos
{kernel, [
#{formatted.each{|f| f.prepend('    ').join(",\n")}}
]}
      eos
      return rendered
    end

    def render_rabbit_parameters
      rendered = <<-eos
{rabbit, [
#{formatted.each{|f| f.prepend('    ').join(",\n")}}
]}
      eos
      return rendered
    end

  end
end

