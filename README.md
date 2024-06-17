# BrewWorks - Project-Specific Development Environment Setup for Mac

BrewWorks is a powerful Homebrew formula that allows you to easily set up project-specific development environments on Mac without using Docker. It enables you to install and manage common services such as PHP, MySQL, Redis, Memcached, Nginx, Apache, and Node.js with customized configurations for each project.

## Features

- Install all necessary services for a project in one go, similar to Docker. 
- Generate custom commands for each project, allowing simple management of the development environment (e.g., `brewworks start`, `. brewworks env`).
- Create a dedicated custom folder for each project to centralize service port numbers, configuration files, and log directories.
- Utilize native Mac services for improved performance compared to Docker.
- Flexibility to add other services as needed.

For a detailed exploration of this approach, its design philosophy, and how it compares to other options, please refer to our [self-review document](docs/self-review).

## Usage

1. Download [brewworks.rb](https://github.com/koriym/homebrew-brewworks/blob/1.x/brewworks.rb) to your project's root directory.

```shell
wget https://raw.githubusercontent.com/koriym/homebrew-brewworks/1.x/brewworks.rb
```

3. Modify the settings in `brewworks.rb` according to your project's requirements:

```ruby
  # Change the following settings
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

3. Rename the file and the class within the file `brewworks.rb` to reflect the PROJECT_NAME you specified. For example, if you set `PROJECT_NAME` to "`myapp`", you should rename the file to `myapp.rb`, and adjust the class name inside the file to `Myapp`.

5. Now, let's proceed with the installation! (Even if you renamed it, you can still use `brewworks` as it is.)

```
brew install ./myapp.rb 
```
And just like that, your project-specific development environment is set up and ready to go.

With BrewWorks, setting up your development environment is incredibly simple and efficient. Unlike traditional setups where you would need to manually install PHP, download Composer, and configure permissions, BrewWorks takes care of all these steps for you. No more hassle of managing multiple dependencies and configurations separately for each project!

Once the installation is complete, you'll have a fully configured, project-specific development environment ready to go. BrewWorks sets up all the necessary services, such as PHP, MySQL, Redis, and more, with optimized configurations tailored to your project's needs.

Let's explore what makes this setup so powerful:

- **Custom Commands**: Easily start and manage your services with intuitive commands. For instance, simply run `brewworks start` to kick off all your services in one go.
- **Centralized Configuration**: All configuration files, log directories, and port numbers are neatly organized in a dedicated folder for your project, making it easy to maintain and update.
- **Improved Performance**: By leveraging native Mac services instead of Docker, you'll experience faster performance and reduced overhead.
- **Flexibility and Extensibility**: BrewWorks is designed to be flexible, allowing you to add additional services and customize configurations as your project evolves.

## Next Steps

1. Start Your Services:

```shell
myapp start
```

This command will start all the services defined in your configuration file.

2. Set Environment Variables:

```shell
. brewworks env
```

This command will set up the necessary environment variables for your project.


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
├── tmp (sys_temp_dir, upload_tmp_dir..)
├── mysql (datbase data folder)
```

This project-specific folder structure makes it easy to manage configuration files and logs for each service and allows for smooth switching between projects.

This formula is a powerful tool that allows you to quickly set up optimized development environments for each project, similar to Docker but using native Mac services. It utilizes Homebrew, a well-known package manager for Mac, making it highly familiar and easy to learn for most Mac developers.

The custom commands and dedicated folders generated for each project simplify the management of development environments, making it intuitive and straightforward. Onboarding new development environments and switching between projects becomes seamless, and sharing a unified development environment within a team is effortless.

## Why BrewWorks?

BrewWorks is an excellent alternative to Docker on Mac, enhancing development efficiency with its customizable, user-friendly interface. Unlike Docker, which relies on virtualization to run Linux containers on Mac, BrewWorks leverages native Mac services for better performance.

Docker's performance on Mac is often hindered by the need to create a virtualized environment that bridges the architectural differences between macOS and Linux. Despite ongoing efforts by developers to optimize Docker for macOS, the inherent overhead of this virtualization layer results in slower performance compared to running services natively.

BrewWorks simplifies the setup process by allowing the installation of PHP, Composer, and other necessary services through Homebrew. This means you only need Homebrew to set up your development environment, reducing complexity.

While Docker remains essential for production environments, BrewWorks offers a streamlined solution for development on Mac. By combining native performance with Homebrew's simplicity, BrewWorks enhances productivity and development experience, making it an invaluable tool for Mac developers.

## Leveraging Project-Centric Development

BrewWorks' unique project-centric approach to configuration management can greatly enhance your development workflow, boost transparency, and promote collaboration within your team.

To learn more about how you can leverage BrewWorks' project-specific directory structure to streamline your development process, check out our in-depth article: [Empowering Project-Centric Development with BrewWorks](docs/brewworks-project-centric-development.md).

This article explores the benefits of bringing configuration files and logs directly into your project's directory, and how this approach can simplify your workflow, improve transparency, and foster a more collaborative development experience.
