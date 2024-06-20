# FAQ and Best Practices

## Will installing unused PHP versions or PECL extensions consume computer resources?

Installing additional PHP versions or PECL extensions that you don't actively use will only consume a small amount of disk space. As long as you don't start services or use these packages, they won't consume other resources like memory or CPU.
Even if you have an unused PHP version like 5.6 installed, it won't impact your system's performance if it's not running. So, don't worry too much about editing the default settings in BrewWorks. It's designed to be easy to use out of the box, and you can always customize it later if needed.

## Do I need to install everything through BrewWorks?

Not at all! BrewWorks is just one formula, and it's not meant to be used exclusively. You can still manually install additional PECL extensions, databases like PostgreSQL, or any other packages you need using brew install, just like you've always done.
BrewWorks is designed to be flexible and work alongside your existing setup. Feel free to use it for your basic PHP environment and add other components manually as needed.
How should I switch between different PHP versions and services?
When working with multiple PHP versions or different sets of services, it's best to switch on a per-session basis rather than globally. This means that instead of using brew link or brew unlink to switch between versions, you should use terminal sessions or terminal tabs dedicated to each project or PHP version.
For example, you can create separate terminal profiles for each PHP version and start a new terminal window or tab with the desired PHP version. This way, you can have multiple projects running simultaneously, each with its own PHP version and set of services, without conflicts.

## Can I use BrewWorks alongside an existing Docker setup?

Yes, absolutely! If you already have a Docker environment set up for certain services that are challenging to configure locally, you can continue using those services in Docker while leveraging BrewWorks for the rest of your stack.
For example, if you have a complex database or message queue service running in Docker, you can keep that service in Docker and use BrewWorks to manage your PHP environment and other local services. BrewWorks' PHP setup is native and optimized for performance, so you can enjoy the benefits of a fast PHP execution while still utilizing Docker for specific services.
To access Docker services from your BrewWorks environment, simply update your project's configuration files (e.g., database connection settings) to point to the Docker service's hostname and port.

## Do I need to maintain BrewWorks itself?

Unlike other utility software, BrewWorks doesn't require maintenance itself. Once you've set up your desired environment, you can even uninstall BrewWorks if you want. The project-specific shell commands created by BrewWorks have hardcoded port numbers and log folder locations, and they are just simple shell commands without dependencies. You can copy and edit them locally even after uninstalling BrewWorks.

## In what scenarios is BrewWorks most useful?

BrewWorks is most useful when you need to quickly set up PHP development environments and customize them for project-specific requirements. Some scenarios where BrewWorks shines include:

- Developing multiple PHP projects simultaneously, each requiring different PHP versions or configurations.
- Building development environments using native services without relying on Docker.
- Sharing consistent environments among development teams, ensuring everyone works with the same setup.

BrewWorks can significantly boost developer productivity in these scenarios.

## How do I manage multiple projects using BrewWorks?

BrewWorks generates a dedicated folder for each project, centralizing service port numbers, configuration files, and log directories. This makes switching between projects seamless.

To switch between project-specific environments, we recommend the following best practices:

1. Use environment variables with ". {yourapp} env` to set the binary path for each session, rather than relying on global switcher tools.
2. Leverage terminal settings to create dedicated profiles for each project or PHP version.
3. Execute BrewWorks commands from any directory, as they are custom-made for each project.

By following these practices, you can easily switch between projects and avoid environment conflicts.

## What are the recommended practices for working with a team using BrewWorks?

When working with a team using BrewWorks, consider the following practices:

1. Keep the BrewWorks configuration file (`brewworks.rb`) under version control (e.g., Git) to ensure all team members share the same setup.
2. Use the configuration file to quickly set up environments for new team members joining the project.
3. Communicate any changes made to the environment to all team members, ensuring everyone applies the same modifications.
4. If services like databases need to be shared, use common port numbers in the configuration file.

Adhering to these practices helps maintain consistent development environments across the team and facilitates smooth collaboration.

## Can Linux and Windows (WSL) users utilize BrewWorks, and what should they do if they encounter a "Too many open files" error?

Yes, Linux users and Windows users with the Windows Subsystem for Linux (WSL) can use BrewWorks. By setting up Homebrew within their Linux environment, they can leverage BrewWorks to manage their PHP development setup.

However, please note that Linux and WSL users might encounter a "Too many open files" error when running BrewWorks due to the default file descriptor limit. If you encounter this error, try increasing the limit by running the following command:

```shell
$> ulimit -n 4096
```shell

If the error persists, you may need to further adjust the limit by modifying the `/etc/security/limits.conf` file within your WSL environment and restarting your WSL instance.

## Why was BrewWorks created?

BrewWorks was created to streamline the process of setting up PHP development environments, addressing the long-standing challenge of building development environments since the inception of PHP. The motivation behind BrewWorks was to provide a simple, efficient, and native solution, particularly for developers who prefer native services over virtualization tools like Docker. The goal was to offer:

- A straightforward and quick setup process.
- A clean approach that doesn't modify global settings, leaving no traces behind when uninstalled.
- Transparency and verifiability, with centralized project-based configurations and logs.
- Easy management of services with custom commands, eliminating the need to remember complex service commands.
- A tool that requires minimal learning curve, leveraging familiar Homebrew formulas.
- High-performance environment utilizing native services, without the overhead of virtualization.
- A free and open-source solution. (requiring no subscription!)

The idea behind BrewWorks was to create a "toolless tool," leveraging Homebrew formulas to fulfill these requirements without the need for a separate software.

## How can I contribute to BrewWorks?

If you have ideas for improving BrewWorks or want to contribute to the project, you can:

Submit bug reports or feature requests on the GitHub issue tracker.
Fork the repository, make your changes, and submit a pull request with your improvements.
Share your experiences, best practices, and tips with the community by writing blog posts or creating tutorials about using BrewWorks in different scenarios.

We welcome and appreciate contributions from the community to make BrewWorks even better!
