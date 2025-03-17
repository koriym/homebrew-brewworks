# DEPRECATED

This package has been moved to a new package [malt](https://github.com/koriym/homebrew-malt).

Future development and maintenance will be conducted in malt. Current users are encouraged to migrate to the new package.

## Migration

1. Uninstall the old package:
```bash
brew uninstall brewworks
brew untap koriym/brewworks
```

2. Install the new package:
```bash
brew tap koriym/malt
brew install malt
```

If you have any questions, please feel free to open an issue in the [malt repository](https://github.com/koriym/homebrew-malt/issues).

---

# BrewWorks - Native and Isolated PHP Development Environments

<img src="https://github.com/koriym/homebrew-brewworks/assets/529021/d02bc876-8c7d-40d6-b2c1-b845d469f7f7" width=45% alt="brewwork logo" >

BrewWorks is a collection of Homebrew formulas designed to simplify the setup and management of PHP development environments on macOS and Linux (including WSL on Windows). It provides two main formulas:

1. **[brewworks](https://koriym.github.io/homebrew-brewworks/README-brewworks.html)**: A powerful formula that allows you to easily set up project-specific development environments with common services such as PHP, MySQL, Redis, Memcached, Nginx, Apache, and Node.js, without using Docker.

2. **[phpcomplete](https://koriym.github.io/homebrew-brewworks/README-phpcomplete.html)**: A formula that enables you to install multiple versions of PHP along with Xdebug and other popular PECL packages, providing a comprehensive PHP development environment.

## brewworks

BrewWorks enables you to install and manage all the necessary services for a project in one go, similar to Docker. It generates custom commands for each project, allowing simple management of the development environment.

For more information on brewworks, its features, and how it compares to Docker, please refer to the [brewworks README](https://koriym.github.io/homebrew-brewworks/README-brewworks.html).

## phpcomplete

PHP Complete allows you to install multiple PHP versions (5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2, 8.3) using the `shivammathur/php` tap. It automatically installs Xdebug for all PHP versions and additional PECL packages for selected PHP versions.

By installing all the required PHP versions using PHP Complete, you can ensure that your development environment remains intact even after uninstalling BrewWorks. This approach saves time and effort in rebuilding the environment from scratch.

For more information on phpcomplete and its features, please refer to the [phpcomplete README][(README-phpcomplete.md](https://koriym.github.io/homebrew-brewworks/README-phpcomplete.html)).

## FAQ and Best Practices

For frequently asked questions and best practices on using BrewWorks, please refer to our [FAQ](FAQ.md). The FAQ covers topics such as resource consumption, integration with existing setups, and contributing to the project.

If you have any additional questions or concerns, feel free to open an issue on our GitHub repository.
