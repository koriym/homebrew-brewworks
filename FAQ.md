# FAQ and Best Practices

### Will installing unused PHP versions or PECL extensions consume computer resources?

Installing additional PHP versions or PECL extensions that you don't actively use will only consume a small amount of disk space. As long as you don't start services or use these packages, they won't consume other resources like memory or CPU.
Even if you have an unused PHP version like 5.6 installed, it won't impact your system's performance if it's not running. So, don't worry too much about editing the default settings in BrewWorks. It's designed to be easy to use out of the box, and you can always customize it later if needed.

### Do I need to install everything through BrewWorks?

Not at all! BrewWorks is just one formula, and it's not meant to be used exclusively. You can still manually install additional PECL extensions, databases like PostgreSQL, or any other packages you need using brew install, just like you've always done.
BrewWorks is designed to be flexible and work alongside your existing setup. Feel free to use it for your basic PHP environment and add other components manually as needed.
How should I switch between different PHP versions and services?
When working with multiple PHP versions or different sets of services, it's best to switch on a per-session basis rather than globally. This means that instead of using brew link or brew unlink to switch between versions, you should use terminal sessions or terminal tabs dedicated to each project or PHP version.
For example, you can create separate terminal profiles for each PHP version and start a new terminal window or tab with the desired PHP version. This way, you can have multiple projects running simultaneously, each with its own PHP version and set of services, without conflicts.

### Can I use BrewWorks alongside an existing Docker setup?

Yes, absolutely! If you already have a Docker environment set up for certain services that are challenging to configure locally, you can continue using those services in Docker while leveraging BrewWorks for the rest of your stack.
For example, if you have a complex database or message queue service running in Docker, you can keep that service in Docker and use BrewWorks to manage your PHP environment and other local services. BrewWorks' PHP setup is native and optimized for performance, so you can enjoy the benefits of a fast PHP execution while still utilizing Docker for specific services.
To access Docker services from your BrewWorks environment, simply update your project's configuration files (e.g., database connection settings) to point to the Docker service's hostname and port.

### Do I need to maintain BrewWorks itself?

Unlike other utility software, BrewWorks doesn't require maintenance itself. Once you've set up your desired environment, you can even uninstall BrewWorks if you want. The project-specific shell commands created by BrewWorks have hardcoded port numbers and log folder locations, and they are just simple shell commands without dependencies. You can copy and edit them locally even after uninstalling BrewWorks.

### How can I contribute to BrewWorks?
If you have ideas for improving BrewWorks or want to contribute to the project, you can:

Submit bug reports or feature requests on the GitHub issue tracker.
Fork the repository, make your changes, and submit a pull request with your improvements.
Share your experiences, best practices, and tips with the community by writing blog posts or creating tutorials about using BrewWorks in different scenarios.

We welcome and appreciate contributions from the community to make BrewWorks even better!
# FAQ and Best Practices

### Will installing unused PHP versions or PECL extensions consume computer resources?

Installing additional PHP versions or PECL extensions that you don't actively use will only consume a small amount of disk space. As long as you don't start services or use these packages, they won't consume other resources like memory or CPU.
Even if you have an unused PHP version like 5.6 installed, it won't impact your system's performance if it's not running. So, don't worry too much about editing the default settings in BrewWorks. It's designed to be easy to use out of the box, and you can always customize it later if needed.

### Do I need to install everything through BrewWorks?

Not at all! BrewWorks is just one formula, and it's not meant to be used exclusively. You can still manually install additional PECL extensions, databases like PostgreSQL, or any other packages you need using brew install, just like you've always done.
BrewWorks is designed to be flexible and work alongside your existing setup. Feel free to use it for your basic PHP environment and add other components manually as needed.
How should I switch between different PHP versions and services?
When working with multiple PHP versions or different sets of services, it's best to switch on a per-session basis rather than globally. This means that instead of using brew link or brew unlink to switch between versions, you should use terminal sessions or terminal tabs dedicated to each project or PHP version.
For example, you can create separate terminal profiles for each PHP version and start a new terminal window or tab with the desired PHP version. This way, you can have multiple projects running simultaneously, each with its own PHP version and set of services, without conflicts.

### Can I use BrewWorks alongside an existing Docker setup?

Yes, absolutely! If you already have a Docker environment set up for certain services that are challenging to configure locally, you can continue using those services in Docker while leveraging BrewWorks for the rest of your stack.
For example, if you have a complex database or message queue service running in Docker, you can keep that service in Docker and use BrewWorks to manage your PHP environment and other local services. BrewWorks' PHP setup is native and optimized for performance, so you can enjoy the benefits of a fast PHP execution while still utilizing Docker for specific services.
To access Docker services from your BrewWorks environment, simply update your project's configuration files (e.g., database connection settings) to point to the Docker service's hostname and port.

### Do I need to maintain BrewWorks itself?

Unlike other utility software, BrewWorks doesn't require maintenance itself. Once you've set up your desired environment, you can even uninstall BrewWorks if you want. The project-specific shell commands created by BrewWorks have hardcoded port numbers and log folder locations, and they are just simple shell commands without dependencies. You can copy and edit them locally even after uninstalling BrewWorks.

### How can I contribute to BrewWorks?
If you have ideas for improving BrewWorks or want to contribute to the project, you can:

Submit bug reports or feature requests on the GitHub issue tracker.
Fork the repository, make your changes, and submit a pull request with your improvements.
Share your experiences, best practices, and tips with the community by writing blog posts or creating tutorials about using BrewWorks in different scenarios.

We welcome and appreciate contributions from the community to make BrewWorks even better!
