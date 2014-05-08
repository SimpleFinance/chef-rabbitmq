# recipes/default.rb
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
# Does a minimal Erlang and RabbitMQ install and adds the necessary pieces.
# This recipe is mostly an example of how you might deploy RabbitMQ, but could
# be used as a foundation.

# It is recommended to uncomment the following lines to receive the latest
# Erlang version, as SSL is poorly supported in older versions.
node.default[:erlang][:install_method] = 'esl'
node.default[:erlang][:esl][:version] = '1:16.b.3-1'
node.default[:rabbitmq][:version] = '3.2.2'
node.default[:rabbitmq][:checksum] = '8ab273d0e32b70cc78d58cb0fbc98bcc303673c1b30265d64246544cee830c63'

include_recipe 'erlang::default'

rabbitmq 'rabbit' do
  version node[:rabbitmq][:version]
  checksum node[:rabbitmq][:checksum]
  action :install
end

rabbitmq_config 'generic' do
  kernel node[:rabbitmq][:kernel]
  rabbit node[:rabbitmq][:rabbit]
  env node[:rabbitmq][:env]
end
