# PHP Complete

PHP Complete is a Homebrew formula that allows you to install multiple versions of PHP along with Xdebug and other popular PECL packages. It simplifies the process of setting up a comprehensive PHP development environment on macOS.

## Features

- Installs multiple PHP versions (`5.6`, `7.0`, `7.1`, `7.2`, `7.3`, `7.4`, `8.0`, `8.1`, `8.2`, `8.3`) using the shivammathur/php tap
- Installs Xdebug for all PHP versions
- Installs additional PECL packages (pcov, apcu, redis, xhprof, imagick, memcached) for selected PHP versions (`8.1`, `8.2`, `8.3`)
- Provides a convenient way to manage PHP extensions and dependencies

# Requirements

- [Homebrew](https://brew.sh/)

# Installation

```shell
brew install phpcomplete
```

This command will install the specified PHP versions, Xdebug, and the additional PECL packages defined in the formula.

## Customization

You can customize the PHP versions and extensions installed by PHP Complete by modifying the formula file.

```shell
brew edit phpcompelete
```

- To exclude specific PHP versions, comment out the corresponding depends_on lines in the formula.
- To change the Xdebug version for a specific PHP version, update the VERSIONS hash in the formula.
- To add or remove PECL packages, modify the EXTENSIONS hash in the formula. Specify the package name as the key and any special installation commands as the value.

Remember to update the `PECL_INSTALL_VERSIONS` array to specify the PHP versions for which the additional PECL packages should be installed.

When you have finished editing, reinstall to reflect the changes.

```shell
brew reinstall phpcomplete
```

## Switching PHP Versions using Terminal Profiles

You can use your terminal software's settings to switch between PHP versions. This allows you to easily open a terminal window using a specific PHP version.

1. Open the terminal's preferences.
2. Select the "Profiles" tab.
3. Click the "+" button to create a new profile.
4. Give the profile a name (e.g., "PHP 8.1").
5. In the "Shell" section, select "Command" and enter the following:

```shell
export PATH="/opt/homebrew/opt/php@8.1/bin:$PATH"
```

6. Save the profile.

Now, whenever you want to use a specific PHP version, you can open a new terminal window or tab and select the corresponding profile from the dropdown menu.

This approach provides a convenient way to switch between PHP versions without modifying global settings or creating separate shell scripts. It keeps your system clean and allows you to have multiple terminal windows open, each using a different PHP version.
