**Table of Contents**

- [RabbitMQ](#rabbitmq)
	- [Usage](#usage)
		- [Platform Support](#platform-support)
		- [About Attributes](#about-attributes)
	- [Resources](#resources)
		- [rabbitmq](#rabbitmq)
		- [rabbitmq\_user](#rabbitmq\_user)
		- [rabbitmq\_vhost](#rabbitmq\_vhost)
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

#### Platform Support
This cookbook only officially supports Ubuntu.

#### About Attributes
This cookbook does not ship with attributes by default. The `default` recipe,
which will do a minimal install, demonstrates how you might choose to install
RabbitMQ, but mostly this cookbook lays down the framework through LWRPs and
libraries.

#### Configuring RabbitMQ
This cookbook does *not* automatically configure RabbitMQ. This is an important
note. However, configuration is managed by really two primary files,
`rabbitmq.config`, and `rabbitmq-env.conf`. They are rendered by default and
can be controlled by a couple attribute namespaces.

* `node[:rabbitmq][:env]` controls [RabbitMQ's environment
  file](http://www.rabbitmq.com/configure.html#define-environment-variables) `rabbitmq-env.conf`
* `node[:rabbitmq][:kernel]` controls the [kernel
  configuration](http://www.erlang.org/doc/man/kernel_app.html) in
  `rabbitmq.config`
* `node[:rabbitmq][:rabbit]` controls the [RabbitMQ-specific configuration](http://www.rabbitmq.com/configure.html#configuration-file) in
  `rabbitmq.config`
* Support for [`mnesia`
  configuration](http://www.erlang.org/doc/man/mnesia.html) is TODO

### Resources
A note about these resources : they all mention an `opts` parameter which maps
to arguments which are passed into the underlying gem, which is powered by
[RabbitMQ's management plugin](http://www.rabbitmq.com/management.html). The 
`opts` parameter looks like this by default :

``` ruby
{
  host: '127.0.0.1',
  port: 15672,
  username: 'guest',
  password: 'guest',
  ssl: {}
}
```

You can override any of these options with the `opts` parameter. In particular,
you might want to override the `ssl` subkey to enable SSL for the session. It 
takes arguments like so :

``` ruby
{
  ...
  ssl: {
    client_cer: '',
    client_key: '',
    ca_file: '',
    ca_path: '',
    cert_store: ''
  }
}
```

Resources attempt to use the same semantics as `rabbitmqctl` for ease of use.

#### rabbitmq
Installs RabbitMQ with the management plugin.

* Available actions : `:install`, `:remove`

Parameters :
* `nodename` : the name of this RabbitMQ/Erlang node (name attribute)
* `user` : name of the RabbitMQ user (default: `rabbitmq`)
* `version` : version of RabbitMQ to install (required)
* `checksum` : checksum of the RabbitMQ package

Example : 
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

#### rabbitmq\_user
This resource manages users in RabbitMQ. Note that the `:add` action is just an
alias to `:update`, which will take multiple actions if necessary (e.g., update a
user's tags and also permissions on the named virtualhost).

* Available actions : `:update`, `:delete`

Parameters :
* `user` : the name of the user to modify (name attribute)
* `password` : password for the user
* `tags` : RabbitMQ tags to give this user
* `permissions` : read, write, configure permissions for this user on the given
  virtualhost (requires `vhost`)
* `vhost` : the virtualhost to commit changes to this user to
* `opts` : a hash of options to pass into the management client

Examples : 
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
  permissions ".* .* .*"
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

* Available actions : `:add`, `:delete`

Parameters:
* `vhost` : name of the virtualhost to act on
* `opts` : a hash of options to pass into the management client

Example : 
``` ruby
rabbitmq_vhost '/testing' do
  action :add
end
```

### TODO
* Runit support
* Policies
* Plugins
* Exchange/queue management?

## Author and License
Simple Finance \<ops@simple.com\>

Apache License, Version 2.0

