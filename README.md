# BrewWorks - Project-Specific Development Environment Setup for Mac

BrewWorks is a powerful Homebrew formula that allows you to easily set up project-specific development environments on Mac without using Docker. It enables you to install and manage common services such as PHP, MySQL, Redis, Memcached, Nginx, Apache, and Node.js with customized configurations for each project.

## Features

- Install all necessary services for a project in one go, similar to Docker. 
- Generate custom commands for each project, allowing simple management of the development environment (e.g., `myapp start`, `source myapp env`).
- Create a dedicated custom folder for each project to centralize service port numbers, configuration files, and log directories.
- Utilize native Mac services for improved performance compared to Docker.
- Flexibility to add other services as needed.

For a detailed exploration of this approach, its design philosophy, and how it compares to other options, please refer to our [self-review document](self-review.md).

## Usage

1. Download [brewworks.rb](https://github.com/koriym/homebrew-brewworks/blob/1.x/brewworks.rb) to your project's root directory.
2. Modify the settings in `brewworks.rb` according to your project's requirements:

```ruby
    PROJECT_NAME = "brewworks"
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
    # The port number for services that do not start is set to zero.
    PORTS = {
      php: 9000,
      mysql: 3306,
      redis: 6379,
      memcached: 11211,
      nginx: 8080,
      httpd: 8081
    }
    PHP_EXTENSIONS = ["xdebug", "pcov", "redis", "memcached"]
```

3. Change the file name as well as the class name in brewworks.rb to match the PROJECT_NAME you have set. For example, if you set the PROJECT_NAME as "myapp", the file name will be myapp.rb, and the class name inside will be Myapp.

4. Lastly, install BrewWorks with the new file name:

```
brew install ./myapp.rb 
```

Try these steps and see if it successfully meets your project's requirements. Let me know if you encounter any problems.

### Managing services

```shell
myapp start      # Start services

myapp stop       # Stop services
````

The project name you specify is the command name. 

### Setting up environment

```
source myapp env
```

This command points `php` and `mysql` to the specified version of the binary.

```shell
% which php
/opt/homebrew/opt/php@8.2/bin/php

% which mysql
mysql: aliased to /opt/homebrew/opt/mysql@8.0/bin/mysql --defaults-file=/opt/homebrew/Cellar/brewworks/1.0.0/myapp/config/my.cnf
```

## Project Structure

BrewWorks generates a dedicated folder for each project:

```shell
myapp
├── config
│   ├── httpd.conf
│   ├── memcached.conf
│   ├── my.cnf
│   ├── nginx.conf
│   ├── nginx_main.conf
│   ├── php-fpm.conf
│   ├── php.ini
│   └── redis.conf
├── logs
│   ├── mysql-error.log
│   ├── nginx-access.log
│   ├── nginx-error.log
│   ├── php-fpm-access.log
│   ├── php-fpm.log
│   └── redis.log
├── public  (Please link your public folder symlink here）
│   └── index.html
├── mysql (datbase data folder)
```

This formula is a powerful tool that allows you to quickly set up optimized development environments for each project, similar to Docker but using native Mac services. It utilizes Homebrew, a well-known package manager for Mac, making it highly familiar and easy to learn for most Mac developers.

The custom commands and dedicated folders generated for each project simplify the management of development environments, making it intuitive and straightforward. Onboarding new development environments and switching between projects becomes seamless, and sharing a unified development environment within a team is effortless.

## Conclusion

BrewWorks is an excellent alternative to Docker on Mac, enhancing development efficiency with its customizable, user-friendly interface. Unlike Docker, which relies on virtualization to run Linux containers on Mac, BrewWorks leverages native Mac services for better performance.

Docker's performance on Mac is often hindered by the need to create a virtualized environment that bridges the architectural differences between macOS and Linux. Despite ongoing efforts by developers to optimize Docker for macOS, the inherent overhead of this virtualization layer results in slower performance compared to running services natively.

BrewWorks simplifies the setup process by allowing the installation of PHP, Composer, and other necessary services through Homebrew. This means you only need Homebrew to set up your development environment, reducing complexity.

While Docker remains essential for production environments, BrewWorks offers a streamlined solution for development on Mac. By combining native performance with Homebrew's simplicity, BrewWorks enhances productivity and development experience, making it an invaluable tool for Mac developers.

