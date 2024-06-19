# BrewWorks - Native and Isolated PHP Development Environments for Mac, without Docker

BrewWorks is a powerful Homebrew formula that allows you to easily set up project-specific development environments on Mac without using Docker. It enables you to install and manage common services such as PHP, MySQL, Redis, Memcached, Nginx, Apache, and Node.js with customized configurations for each project.

## Features

- Install all necessary services for a project in one go, similar to Docker.
- Generate custom commands for each project, allowing simple management of the development environment (e.g., `myapp start`, `myapp stop`).
- Create a dedicated custom folder for each project to centralize service port numbers, configuration files, and log directories.
- Utilize native Mac services for improved performance compared to Docker.
- Flexibility to add other services as needed.

For a detailed exploration of this approach, its design philosophy, and how it compares to other options, please refer to our [self-review document](docs/self-review.md).

## Quick Install

If you simply want a quick PHP development environment or are a beginner, try this method.
You can build an environment in no time. All you need is homebrew.

```shell
brew install koriym/brewworks/brewworks
```

Next, open the formula and set up your dependencies.
(If you don't know what it says, just close it. No problem.)

```shell
brew edit brewworks
```

If you have made any edits, Reinstall to reflect them.

``shell
brew reinstall brewworks
````

Now start the services! All necessary services will be started at once.

``shell
brewworks start
```

You should be able to see it at http::localhost:8080/ .

Edit the configuration file in ``$(brew --prefix)/opt/brewworks/conf/`` for further development.

## Custome Install

"Quick Install" built a single environment quickly, but here you can build for multiple projects or a project-specific build with the formula as a local file to share the build with other members of the team.

1. Download [brewworks.rb](https://github.com/koriym/homebrew-brewworks/blob/1.x/brewworks.rb) to your project's root directory.

```shell
wget https://raw.githubusercontent.com/koriym/homebrew-brewworks/1.x/brewworks.rb
```

3. Modify the settings in `brewworks.rb` according to your project's requirements:

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
    PORTS = {
      php: [9000],
      mysql: [3306, 3307],
      redis: [6379],
      memcached: [11211],
      nginx: [8080],
      httpd: [0]
    }
    # The port number for services that do not start is set to zero.
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

One of the standout features of BrewWorks is the ability to start all the necessary services for your project with a single command. This is a huge time-saver and makes managing your development environment a breeze.

2. Set Environment Variables:

```shell
. brewworks env
````

This environment variable setting causes php and mysql to point to the specified version of the binary. In addition to that, an alias mysql@3306, the client for each mysql service port, is created. This is useful for quick connections with argument-free commands and is easy to customize as it loads a project-specific my.conf.

These simple yet powerful commands, unique to BrewWorks, dramatically simplify the management of your development environment. No more navigating through complex docker-compose files or manually starting and stopping individual services. With BrewWorks, you can control your entire development stack with ease and efficiency.

## Project Structure

BrewWorks generates a dedicated folder for each project:

```shell
myapp
├── config
│  ├── httpd_8082.conf
│  ├── memcached_11212.conf
│  ├── my_3306.cnf
│  ├── my_3307.cnf
│  ├── nginx_8080.conf
│  ├── nginx_main.conf
│  ├── php-fpm_9000.conf
│  ├── php.ini
│  └── redis_6379.conf
├── logs
│  ├── php-fpm-access_9000.log
│  ├── php-fpm_9000.log
│  └── redis_6379.log
├── public
│  └── index.html
├── tmp (sys_temp_dir, upload_tmp_dir..)
├── mysql_0 (datbase data folder)
├── mysql_1
```

This project-specific folder structure makes it easy to manage configuration files and logs for each service and allows for smooth switching between projects.

This formula is a powerful tool that allows you to quickly set up optimized development environments for each project, similar to Docker but using native Mac services. It utilizes Homebrew, a well-known package manager for Mac, making it highly familiar and easy to learn for most Mac developers.

The custom commands and dedicated folders generated for each project simplify the management of development environments, making it intuitive and straightforward. Onboarding new development environments and switching between projects becomes seamless, and sharing a unified development environment within a team is effortless.

## Uninstall

Uninstallation is also easy: the brew `uninstall` command will erase all unique files, including database folders. This also means that you can reset the environment at any time with the `reinstall` command. The database is also initialised.

```shell
myapp stop
brew uninstall ./myapp.rb 
```

## Why BrewWorks?

BrewWorks is an excellent alternative to Docker on Mac, enhancing development efficiency with its customizable, user-friendly interface. Unlike Docker, which relies on virtualization to run Linux containers on Mac, BrewWorks leverages native Mac services for better performance.

Docker's performance on Mac is often hindered by the need to create a virtualized environment that bridges the architectural differences between macOS and Linux. Despite ongoing efforts by developers to optimize Docker for macOS, the inherent overhead of this virtualization layer results in slower performance compared to running services natively.

BrewWorks simplifies the setup process by allowing the installation of PHP, Composer, and other necessary services through Homebrew. This means you only need Homebrew to set up your development environment, reducing complexity.

While Docker remains essential for production environments, BrewWorks offers a streamlined solution for development on Mac. By combining native performance with Homebrew's simplicity, BrewWorks enhances productivity and development experience, making it an invaluable tool for Mac developers.

## Leveraging Project-Centric Development

BrewWorks' unique project-centric approach to configuration management can greatly enhance your development workflow, boost transparency, and promote collaboration within your team.

To learn more about how you can leverage BrewWorks' project-specific directory structure to streamline your development process, check out our in-depth article: [Empowering Project-Centric Development with BrewWorks](docs/brewworks-project-centric-development.md).

This article explores the benefits of bringing configuration files and logs directly into your project's directory, and how this approach can simplify your workflow, improve transparency, and foster a more collaborative development experience.
