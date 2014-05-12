**Table of Contents**

- [RabbitMQ](#rabbitmq)
	- [Usage](#usage)
		- [Platform Support](#platform-support)
		- [About Attributes](#about-attributes)
	  - [Configuring RabbitMQ](#configuring-rabbitmq)
     - [Example Recipe](#example-recipe)
	- [Resources](#resources)
		- [rabbitmq](#rabbitmq)
		- [rabbitmq\_user](#rabbitmq\_user)
		- [rabbitmq\_vhost](#rabbitmq\_vhost)
		- [rabbitmq\_config](#rabbitmq\_config)
		- [rabbitmq\_exchange](#rabbitmq\_exchange)
		- [rabbitmq\_queue](#rabbitmq\_queue)
		- [rabbitmq\_binding](#rabbitmq\_binding)
		- [rabbitmq\_policy](#rabbitmq\_policy)
	- [TODO](#todo)
- [Author and License](#author-and-license)

## RabbitMQ
A Chef cookbook for managing, installing, and configuring RabbitMQ, an Erlang
message queue application. This cookbook is powered in particular by the
[rabbitmq\_http\_api\_client
gem](https://github.com/ruby-amqp/rabbitmq_http_api_client) and the [amqp
gem](https://github.com/ruby-amqp/amqp). As such, it forces the management API
to be available, and can accomplish anything from queue management to user
creation and deletion.

### Usage
This cookbook attempts to maintain some backwards-compatibility with the
[Opscode RabbitMQ cookbook](https://github.com/opscode-cookbooks/rabbitmq), but
has some changes that will require attention in the event of a migration.

It also provides helpers to make RabbitMQ config rendering nice and easy.

Although the "Example Recipe" will work fine, the recommended pattern is to use
this cookbook as a library, calling resources as appropriate to install
RabbitMQ, manage its configuration, and deploy the correct topology to support
your infrastructure.

#### Platform Support
This cookbook only officially supports Ubuntu. Pull requests accepted for other
operating systems!

#### About Attributes
This cookbook does not ship with attributes by default. The "Example Recipe"
below demonstrates how you might choose to install RabbitMQ, but mostly this 
cookbook lays down the framework through LWRPs and libraries.

#### Configuring RabbitMQ
This cookbook does *not* automatically configure RabbitMQ. This is an important
note. However, configuration is managed by really two primary files,
`rabbitmq.config`, and `rabbitmq-env.conf`. They are rendered by the
`rabbitmq_config` resource and can be controlled by a couple attribute 
namespaces. We recommend the following pattern :

* `node[:rabbitmq][:env]` controls [RabbitMQ's environment
  file](http://www.rabbitmq.com/configure.html#define-environment-variables) `rabbitmq-env.conf`
* `node[:rabbitmq][:kernel]` controls the [kernel
  configuration](http://www.erlang.org/doc/man/kernel_app.html) in
  `rabbitmq.config`
* `node[:rabbitmq][:rabbit]` controls the [RabbitMQ-specific configuration](http://www.rabbitmq.com/configure.html#configuration-file) in
  `rabbitmq.config`
* A note : Support for [mnesia
  configuration](http://www.erlang.org/doc/man/mnesia.html) is TODO

This avoids attribute collisions and gives a sane structure to these parameters;
however, all the resource parameters simply take a hash which maps the 
parameters to values.

#### Example Recipe
The following is an example of how one might use this cookbook to install and
manage RabbitMQ.

``` ruby
node.override[:erlang][:install_method] = 'esl'
node.override[:erlang][:esl][:version] = '1:16.b.3-1'
node.override[:rabbitmq][:version] = '3.2.2'
node.override[:rabbitmq][:checksum] = '8ab273d0e32b70cc78d58cb0fbc98bcc303673c1b30265d64246544cee830c63'

include_recipe 'erlang::default'

rabbitmq 'rabbit' do
  version node[:rabbitmq][:version]
  checksum node[:rabbitmq][:checksum]
  action :install
end

rabbitmq_config 'rabbit' do
  kernel node[:rabbitmq][:kernel]
  rabbit node[:rabbitmq][:rabbit]
  env node[:rabbitmq][:env]
end

rabbitmq_vhost '/test' do
  action :add
end

rabbitmq_user 'tester' do
  password 'hi'
  action :update
end

rabbitmq_exchange 'test.exchange' do
  vhost '/test'
  action :declare
end

rabbitmq_queue 'my_queue' do
  vhost '/test'
  action :declare
end

rabbitmq_binding 'my_binding' do
  vhost '/test'
  exchange 'test.exchange'
  queue 'my_queue'
  action :declare
end

```

### Resources
This cookbook uses the Management API to power everything. As such, it will
default to the following URL for making changes:

`http://guest:guest@127.0.0.1:15672`

If you want to change any of these parameters, there are special attributes
that you can set which will automatically override the corresponding value.
They reside under `node[:rabbitmq]` and are defined as follows:

``` ruby
{
  admin_host: '127.0.0.1',
  admin_port: 15672,
  admin_user: 'guest',
  admin_pass: 'guest',
  admin_ssl_opts: {}
}
```

SSL support has not been thoroughly tested and so might be buggy! Apologies for
this, but fixes soon.

Resources attempt to use the same semantics as `rabbitmqctl` for ease of use.

#### rabbitmq
Installs RabbitMQ with the management plugin.

* Available actions: `:install`, `:remove`

Parameters:
* `nodename` : the name of this RabbitMQ/Erlang node (name attribute)
* `user` : name of the RabbitMQ user (default: `rabbitmq`)
* `version` : version of RabbitMQ to install (required)
* `checksum` : checksum of the RabbitMQ package

Example: 
``` ruby
rabbitmq 'rabbit' do
  version '3.2.2'
  checksum '8ab273d0e32b70cc78d58cb0fbc98bcc303673c1b30265d64246544cee830c63'
  action :install
end
```

[?] Wondering how to figure out the checksum for a version? Access the
[RabbitMQ downloads page](http://www.rabbitmq.com/releases/rabbitmq-server/)
and run `shasum -a 256 /path/to/downloaded/file.deb`.

#### rabbitmq\_config
Manages rabbitmq.config and rabbitmq-env.conf. Out of the box, the vanilla
`rabbitmq` resource will give a working configuration. However, if you want to
change the config, it is recommended you use this resource.

* Available actions: `:render`, `:delete`

Parameters: 
* `nodename` : An identifier for the configuration you're using (name attribute)
* `kernel` : kernel application parameters
* `rabbit` : RabbitMQ-specific parameters
* `env` : RabbitMQ environment variables

None of these are required; however, RabbitMQ might fail to boot depending on
the configuration you feed in (for example, leaving all of these blank will
prevent RabbitMQ from booting), so use caution. The `default` recipe
demonstrates how you might choose to deploy this, namespacing each of the
parameters under `node[:rabbitmq][:<param>]`.

Example: 
``` ruby
rabbitmq_config 'ssl' do
  kernel node[:rabbitmq][:kernel]
  rabbit node[:rabbitmq][:rabbit]
  env node[:rabbitmq][:env]  
end
```

#### rabbitmq\_user
This resource manages users in RabbitMQ. Note that the `:add` action is just an
alias to `:update`, which will take multiple actions if necessary (e.g., update a
user's tags and also permissions on the named virtualhost).

* Available actions: `:add`, `:update`, `:delete`
* Note: `:add` and `:update` are equivalent

Parameters:
* `user` : the name of the user to modify (name attribute)
* `password` : password for the user
* `tags` : RabbitMQ tags to give this user
* `permissions` : read, write, configure permissions for this user on the given
  virtualhost (requires `vhost`)
* `vhost` : the virtualhost to commit changes to this user to

Examples: 
``` ruby
# Create 'waffle' user
rabbitmq_user 'waffle' do
  password 'changeme'
  tags ['my_user']
  action :update
end

# Update waffle's permissions to /testing
rabbitmq_user 'waffle' do
  permissions '.* .* .*'
  vhost '/testing'
  action :update
end

# Create 'pancake' user and give permissions on '/another' vhost
rabbitmq_user 'pancake' do
  password 'insecure'
  permissions '.* .* .*'
  vhost '/another'
  action :update
end

# We don't need this user anymore
rabbitmq_user 'waffle' do
  action :delete
end
```

#### rabbitmq\_vhost
This resource manages virtualhosts.

* Available actions: `:add`, `:delete`

Parameters:
* `vhost` : name of the virtualhost to act on

Example: 
``` ruby
rabbitmq_vhost '/testing' do
  action :add
end
```

#### rabbitmq\_exchange
Adds a RabbitMQ exchange to a given virtualhost.

* Available actions: `:declare`, `:delete`

Parameters:
* `exchange` : name of the exchange to add
* `vhost` : virtualhost to which the exchange should be added
* `attrs` : attributes to give to the exchange

Example:
``` ruby
rabbitmq_exchange 'test.exchange' do
  vhost '/test'
  action :declare
end
```

#### rabbitmq\_queue
Adds a RabbitMQ queue to a given virtualhost.

* Available actions: `:declare`, `:delete`

Parameters:
* `queue` : name of the queue to add
* `vhost` : virtualhost to add the queue to
* `attrs` : attributes for the queue

Example:
``` ruby
rabbitmq_queue 'test_queue' do
  vhost '/test'
  action :declare
end
```

#### rabbitmq\_binding
Binds together a queue and exchange.

* Available actions: `:declare`, `:delete`

Parameters:
* `binding` : name of the binding to declare
* `vhost` : virtualhost on which the binding will be declared
* `exchange` : the exchange to bind the queue to
* `queue` : the queue to bind
* `routing_key` : the routing key for the 
* `props_key` : still unsure ...

Example:
``` ruby
rabbitmq_binding 'test_binding' do
  vhost '/test'
  exchange 'test.exchange'
  queue 'test_queue'
  routing_key 'hi'
end
```

#### rabbitmq\_policy
Applies a [policy](https://www.rabbitmq.com/parameters.html#policies) to a RabbitMQ virtualhost.

* Available actions: `:set`, `:clear`

Parameters:
* `name` : the name of the policy (name attribute)
* `vhost` : virtualhost on which the policy will be applied
* `pattern` : a regular expression for which queues/exchanges the policy will
  filter for
* `definition` : hash representing the exact parameters to set
* `priority` : priority of the policy (precedence increases with numeric value)
* `apply_to` : which of `'queues'`, `'exchanges'`, or `'all'` to apply the
  policy to

Example:
``` ruby
rabbitmq_policy 'ha-all' do
  vhost '/test'
  pattern '.*'
  definition {'ha-mode' => 'all', 'ha-sync-mode' => 'automatic'}
  priority 1
end
```

### TODO
* Plugins
* Runit support
* Clustering support
* TESTS! Lots of them!

## Author and License
Simple Finance \<ops@simple.com\>

Apache License, Version 2.0
