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

```shell
brew reinstall brewworks
```

Now start the services! All necessary services will be started at once.

```shell
brewworks start
```

You should be able to see it at http::localhost:8080/ .

Edit the configuration file in ``$(brew --prefix)/opt/brewworks/conf/`` for further development.

## Custome Install

For multiple projects or a project-specific setup, you can use the formula as a local file to share the build with other members of the team.

1. Download [brewworks.rb](https://github.com/koriym/homebrew-brewworks/blob/1.x/brewworks.rb) to your project's root directory.

```shell
wget https://raw.githubusercontent.com/koriym/homebrew-brewworks/1.x/brewworks.rb
```

2. Modify the settings in `brewworks.rb` according to your project's requirements.

3. Rename the file and the class within the file `brewworks.rb` to reflect the PROJECT_NAME you specified.

4. Install the formula.

```shell
brew install ./myapp.rb
```

Your project-specific development environment is now set up and ready to go!

BrewWorks automates the installation of PHP and Composer, eliminating the need for manual setups and permission configurations. Once the installation is complete, you'll have a fully configured, project-specific development environment ready to go. BrewWorks sets up all the necessary services, such as PHP, MySQL, Redis, and more, with optimized configurations tailored to your project's needs.

## Usage


1. Start Your Services:

```shell
myapp start
```

2. Stop All Services:

```shell
myapp stop
```

2. Set Environment Variables:

```shell
. brewworks env
````

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

## Uninstall

Uninstallation is also easy: the `brew uninstall` command will erase all unique files, including database folders. This also means that you can reset the environment at any time with the `reinstall` command. The database is also initialized.

```shell
myapp stop
brew uninstall ./myapp.rb 
```

## Why BrewWorks?

BrewWorks is an excellent alternative to Docker on Mac, enhancing development efficiency with its customizable, user-friendly interface. Unlike Docker, which relies on virtualizing Linux containers to run on macOS, BrewWorks leverages native Mac services for better performance.

BrewWorks simplifies the setup process by allowing the installation of PHP, Composer, and other necessary services through Homebrew, reducing complexity.

While Docker is crucial for production, BrewWorks provides an optimized alternative for Mac development. By combining native performance with Homebrew's simplicity, BrewWorks enhances productivity and development experience, making it an invaluable tool for Mac developers.

For a detailed comparison of BrewWorks with Docker, please refer to our comparison article.

## Leveraging Project-Centric Development

To learn more about how you can leverage BrewWorks' project-specific directory structure to streamline your development process, check out our in-depth article: Empowering Project-Centric Development with BrewWorks.
