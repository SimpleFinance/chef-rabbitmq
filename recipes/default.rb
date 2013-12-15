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
# Does a minimal Erlang and RabbitMQ install and adds the necessary pieces

include_recipe 'erlang::default'

chef_gem 'amqp' do
  action :nothing
end.run_action(:install)

chef_gem 'rabbitmq_http_api_client' do
  action :nothing
end.run_action(:install)

rabbitmq 'application' do
  action :install
end

