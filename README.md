# BrewWorks- Project-Specific Development Environment Setup for Mac

This Homebrew formula is a powerful tool that allows you to easily set up project-specific development environments on Mac without using Docker. It enables you to install and manage common services such as PHP, MySQL, Redis, Memcached, Nginx, Apache, and Node.js with customized configurations for each project.
Features

Install all necessary services for a project in one go, similar to Docker. Services not in use can be skipped by specifying port 0.
Generate custom commands for each project, allowing simple management of the development environment (e.g., myapp start, source myapp env).
Create a dedicated custom folder for each project to centralize service port numbers, configuration files, and log directories.
Utilize native Mac services for improved performance compared to Docker.
Flexibility to add other services as needed.

## A New Choice for Project-Specific Dependency Management

This Homebrew formula offers a new approach to project-specific dependency management on Mac, providing an alternative to traditional global Homebrew installations and Docker-based setups. It combines the simplicity of Homebrew with the isolation benefits of project-specific environments.

For a detailed exploration of this approach and how it compares to other options, please refer to our article: [Homebrew Formula: A New Choice for Project-Specific Dependency Management on Mac](link-to-the-article).

## Usage

1. Copy this formula (brewworks.rb) to your project's root directory.
1. Modify the following settings in the formula according to your project's requirements:

```
PROJECT_NAME = "myapp"
PHP_VERSION = "8.3"
MYSQL_VERSION = "8.0"
DEPENDENCIES = [
  "php@#{PHP_VERSION}",
  "mysql@#{MYSQL_VERSION}",
  "redis",
  "memcached",
  "nginx",
  "httpd",
  "composer",
  "node"
]
PORTS = {
  php: 9001,
  mysql: 3307,
  redis: 6379,
  memcached: 11211,
  nginx: 8080,
  apache: 0 # no install
}
PHP_EXTENSIONS = ["xdebug", "pcov"]
```
3. Execute the following command

```shell
brew install ./brewworks.rb
```

- The required services and project-specific commands are generated based on the specification.
- The name specified in PROJECT_NAME becomes the command name.

```shell
$ myapp

Usage: myapp {env|start|stop}
Commands:
  source myproject env  - Set the environment variables for the project.
  myproject start       - Start the project services.
  myproject stop        - Stop the project services.
```

### Start services

```shell
myapp start
```

The installed `myapp` command does not look at files in local directories. It is the same no matter where you operate it from.

### Stop services

```shell
myapp stop
```

### Specify binary version

```shell
source myapp env
```
It will cause `php` and `mysql` to point to the specified version of the binary.

```shell
$ source myproject env

$ which php
/opt/homebrew/opt/php@8.3/bin/php

$ which mysql
/opt/homebrew/opt/mysql@8.0/bin/mysql
```

This formula is a powerful tool that allows you to quickly set up optimized development environments for each project, similar to Docker but using native Mac services. It utilizes Homebrew, a well-known package manager for Mac, making it highly familiar and easy to learn for most Mac developers.
The custom commands and dedicated folders generated for each project simplify the management of development environments, making it intuitive and straightforward. Onboarding new development environments and switching between projects becomes seamless, and sharing a unified development environment within a team is effortless.

```shell
myapp
├── config
│   ├── httpd.conf
│   ├── memcached.conf
│   ├── my.cnf
│   ├── nginx.conf
│   ├── nginx_main.conf
│   ├── php-fpm.conf
│   ├── php.ini
│   └── redis.conf
├── logs
└── public
    └── index.html

```

With its flexibility to customize according to project-specific requirements and a simple, user-friendly interface, this formula is an excellent alternative to Docker on Mac, significantly boosting development efficiency.