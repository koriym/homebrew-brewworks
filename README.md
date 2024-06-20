# BrewWorks - Native and Isolated PHP Development Environments for Mac

BrewWorks is a collection of Homebrew formulas designed to simplify the setup and management of PHP development environments on Mac. It provides two main formulas:

1. **[brewworks](brewworks.rb)**: A powerful formula that allows you to easily set up project-specific development environments with common services such as PHP, MySQL, Redis, Memcached, Nginx, Apache, and Node.js, without using Docker.

2. **[phpcomplete](phpcomplete.rb)**: A formula that enables you to install multiple versions of PHP along with Xdebug and other popular PECL packages, providing a comprehensive PHP development environment.

## brewworks

BrewWorks enables you to install and manage all the necessary services for a project in one go, similar to Docker. It generates custom commands for each project, allowing simple management of the development environment (e.g., `myapp start`, `myapp stop`).

For more information on brewworks, its features, and how it compares to Docker, please refer to the [brewworks README](brewworks.rb).

## phpcomplete

PHP Complete allows you to install multiple PHP versions (5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3) using the `shivammathur/php` tap. It automatically installs Xdebug for all PHP versions and additional PECL packages for selected PHP versions.

By installing all the required PHP versions using PHP Complete, you can ensure that your development environment remains intact even after uninstalling BrewWorks. This approach saves time and effort in rebuilding the environment from scratch.

For more information on phpcomplete and its features, please refer to the [phpcomplete README](phpcomplete.rb).

## FAQ and Best Practices

For frequently asked questions and best practices on using BrewWorks, please refer to our [FAQ](FAQ.md). The FAQ covers topics such as:

- Resource consumption by unused packages
- Using BrewWorks alongside manual Homebrew installations
- Switching between PHP versions and services
- Integrating with existing Docker setups
- Maintenance and customization of BrewWorks
- Contributing to the project

If you have any additional questions or concerns, feel free to open an issue on our GitHub repository.