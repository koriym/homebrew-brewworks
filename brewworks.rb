require "pathname"
require "etc"

class Brewworks < Formula
  url "file:///dev/null"
  version "1.1.0"

  # -- Begin Configuration Section --

  # Project name (used for directories and other references)
  PROJECT_NAME = "brewworks"

  # PHP version (reflected in dependencies and config files)
  LANG_VERSION = "8.3"

  # Define dependencies for needed services and tools
  # Each service can be specified with a version if necessary.
  # Uncomment PostgreSQL if you want to enable it.
  DEPENDENCIES = [
    "php@#{LANG_VERSION}",  # PHP (specified version)
    "composer",             # PHP package manager
    "redis",                # Redis cache server
    "nginx",                # Nginx web server
    "httpd",                # Apache web server
    "mysql@8.0",            # MySQL database (8.0)
  # "postgresql@15"       # PostgreSQL database (commented out by default)
  ].compact

  # Dynamically enable database services based on the items in DEPENDENCIES
  ENABLED_DATABASES = {
    mysql: DEPENDENCIES.any? { |dep| dep.start_with?("mysql@") },
    postgresql: DEPENDENCIES.any? { |dep| dep.start_with?("postgresql@") }
  }

  # Define ports for each service.
  # Default ports are listed, and database ports are added only if the service is enabled.
  PORTS = {
    php: [9000],        # PHP-FPM
    redis: [6379],      # Redis
    memcached: [11211], # Memcached
    nginx: [80, 443],   # Nginx (HTTP/HTTPS)
    httpd: [8080, 8443] # Apache (HTTP/HTTPS)
  }.tap do |ports|
    ports[:mysql] = [3306] if ENABLED_DATABASES[:mysql]
    ports[:postgresql] = [5432] if ENABLED_DATABASES[:postgresql]
  end

  # List of PHP extensions required for this project
  # They will be installed via Homebrew or PECL.
  PHP_EXTENSIONS = [
    "xdebug",     # Debugging and development
    "redis",      # Redis integration
    "memcached",  # Memcached integration
    "opcache",    # PHP opcode cache
    "apcu"        # User cache
  ]

  # -- End Configuration Section --

  #
  # Installer
  #
  DEPENDENCIES.each { |dep| depends_on dep }
  def install
    ohai "Starting brewworks installation."
    ohai "Note: BrewWorks manages specific versions of PHP packages (php@#{LANG_VERSION})."
    ohai "If you already have PHP packages installed without a specified version, there may be conflicts."
    ohai ""

    # Initialize directory structure
    @project_dir = Pathname.new(prefix) / PROJECT_NAME
    @script_dir = Pathname.new(prefix) / "script"
    @public_dir = @project_dir / "public"
    @log_dir = @project_dir / "logs"
    @tmp_dir = @project_dir / "tmp"
    @config_dir = @project_dir / "config"
    @php_lib_path = "#{HOMEBREW_PREFIX}/opt/php@#{LANG_VERSION}/lib/httpd/modules/libphp.so"

    # Create directories
    [@public_dir, @config_dir, @script_dir, @tmp_dir, @log_dir].each(&:mkpath)
    (@tmp_dir / ".gitkeep").write("")
    (@log_dir / ".gitkeep").write("")

    # Write default files
    write_public_index
    write_config_files
    write_env_script
    write_manage_services_script

    # Initialize databases if enabled
    init_databases

    # Create symlink for manage_services script
    bin.install_symlink @script_dir / "manage_services.sh" => PROJECT_NAME
  end

  # Homebrew は caveats をパブリックメソッドとして呼び出すため、ここではプライベートブロックの外に記述します
  def caveats
    <<~EOS
      Your BrewWorks directory successfully made in:
        #{prefix}/#{PROJECT_NAME}

      To manage the services, run:
        source #{PROJECT_NAME} env  - Set the environment variables for the project.
        #{PROJECT_NAME} start       - Start the project services.
        #{PROJECT_NAME} stop        - Stop the project services.

      Configuration files are located in:
        #{prefix}/#{PROJECT_NAME}/config/
        Please edit these files as needed.

      Log files are located in:
        #{prefix}/#{PROJECT_NAME}/logs/

      Web document Root is located in:
        #{prefix}/#{PROJECT_NAME}/public

      Create symlink to Web document root from your project:
        ln -fs /full_path_to_your/public #{prefix}/#{PROJECT_NAME}/public
    EOS
  end

  private

  def init_databases
    init_mysql_db if ENABLED_DATABASES[:mysql]
    init_postgresql_db if ENABLED_DATABASES[:postgresql]
  end

  def init_mysql_db
    user = Etc.getlogin
    PORTS[:mysql].each_with_index do |port, index|
      system "#{HOMEBREW_PREFIX}/opt/mysql@8.0/bin/mysqld",
             "--initialize-insecure",
             "--datadir=#{@project_dir}/mysql_#{index}",
             "--user=#{user}"
    end
  end

  def init_postgresql_db
    user = Etc.getlogin
    PORTS[:postgresql].each do |port|
      pg_dir = "#{@project_dir}/postgresql_#{port}"
      system "#{HOMEBREW_PREFIX}/opt/postgresql@15/bin/initdb",
             "-D", pg_dir,
             "--username=#{user}",
             "--locale=C",
             "--encoding=UTF8"
    end
  end

  def write_public_index
    (@public_dir / "index.html").write <<~HTML
      <html>
        <body>
          <h1>It works!</h1>
          <p>This is a placeholder. To link your project's public directory, run:</p>
          <pre>ln -fs /full_path/to/your_project/public #{@public_dir}</pre>
        </body>
      </html>
    HTML
  end

  def write_config_files
    write_php_configs
    write_database_configs
    write_cache_configs
    write_webserver_configs
  end

  def write_php_configs
    # PHP-FPM configuration
    PORTS[:php].each do |port|
      (@config_dir / "php-fpm_#{port}.conf").write <<~CONF
        [global]
        daemonize = no
        error_log = #{@log_dir}/php-fpm_#{port}.log

        [www]
        listen = 127.0.0.1:#{port}
        pm = dynamic
        pm.max_children = 20
        pm.start_servers = 5
        pm.min_spare_servers = 3
        pm.max_spare_servers = 7
        access.log = #{@log_dir}/php-fpm-access_#{port}.log
        slowlog = #{@log_dir}/php-fpm-slow_#{port}.log
      CONF
    end

    # PHP configuration
    ext_list, extension_dir = get_php_extensions
    (@config_dir / "php.ini").write <<~EOS
      memory_limit = 2048M
      error_log = #{@log_dir}/php-error.log
      sys_temp_dir = #{@tmp_dir}
      upload_tmp_dir = #{@tmp_dir}
      xdebug.output_dir = #{@tmp_dir}
      extension_dir = #{extension_dir}
    EOS
  end

  def write_database_configs
    if ENABLED_DATABASES[:mysql]
      PORTS[:mysql].each_with_index do |port, index|
        (@config_dir / "my_#{port}.cnf").write <<~CONF
          [mysqld]
          port = #{port}
          socket = #{@tmp_dir}/mysql_#{port}.sock
          log-error = #{@log_dir}/mysql_#{port}_error.log
          general_log_file = #{@log_dir}/mysql_#{port}_general.log
          slow_query_log_file = #{@log_dir}/mysql_#{port}_slow.log
          datadir = "#{@project_dir}/mysql_#{index}"
          pid-file = "#{@project_dir}/mysql_#{index}/mysqld.pid"

          [client]
          user = root
          port = #{port}
          socket = #{@tmp_dir}/mysql_#{port}.sock

          [mysql]
          prompt = mysql@#{port}:\\d>\\_
        CONF
      end
    end

    if ENABLED_DATABASES[:postgresql]
      PORTS[:postgresql].each do |port|
        (@config_dir / "postgresql_#{port}.conf").write <<~CONF
          port = #{port}
          unix_socket_directories = '#{@tmp_dir}'
          log_directory = '#{@log_dir}'
          log_filename = 'postgresql_#{port}_%Y-%m-%d_%H%M%S.log'
          logging_collector = on
          log_min_messages = warning
          log_min_error_statement = error
          log_min_duration_statement = 1000
          data_directory = '#{@project_dir}/postgresql_#{port}'
        CONF
      end
    end
  end

  def write_cache_configs
    # Redis configuration
    PORTS[:redis].each do |port|
      (@config_dir / "redis_#{port}.conf").write <<~CONF
        port #{port}
        logfile #{@log_dir}/redis_#{port}.log
        dir #{@tmp_dir}
      CONF
    end

    # Memcached configuration
    PORTS[:memcached].each do |port|
      (@config_dir / "memcached_#{port}.conf").write <<~CONF
        -p #{port}
        -l 127.0.0.1
        -vv >> #{@log_dir}/memcached_#{port}.log 2>&1
      CONF
    end
  end

  def write_webserver_configs
    # Nginx configuration
    PORTS[:nginx].each do |port|
      (@config_dir / "nginx_#{port}.conf").write <<~CONF
        server {
          listen #{port};
          server_name localhost;
          root #{@public_dir};
          index index.php index.html index.htm;

          access_log #{@log_dir}/nginx_#{port}_access.log;
          error_log #{@log_dir}/nginx_#{port}_error.log;

          location / {
            try_files $uri $uri/ /index.php?$query_string;
          }

          location ~ \.php$ {
            include #{HOMEBREW_PREFIX}/etc/nginx/fastcgi_params;
            fastcgi_pass 127.0.0.1:#{PORTS[:php].first};
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
          }
        }
      CONF
    end

    # Apache configuration
    PORTS[:httpd].each do |port|
      (@config_dir / "httpd_#{port}.conf").write <<~CONF
        Listen #{port}
        DocumentRoot "#{@public_dir}"
        <Directory "#{@public_dir}">
          Options Indexes FollowSymLinks
          AllowOverride All
          Require all granted
        </Directory>
        LoadModule php_module #{@php_lib_path}
        <FilesMatch \.php$>
          SetHandler application/x-httpd-php
        </FilesMatch>

        ErrorLog #{@log_dir}/httpd_#{port}_error.log

        LoadModule unixd_module "#{HOMEBREW_PREFIX}/opt/httpd/lib/httpd/modules/mod_unixd.so"
        LoadModule mpm_prefork_module "#{HOMEBREW_PREFIX}/opt/httpd/lib/httpd/modules/mod_mpm_prefork.so"
        LoadModule authz_core_module "#{HOMEBREW_PREFIX}/opt/httpd/lib/httpd/modules/mod_authz_core.so"
        LoadModule authz_host_module "#{HOMEBREW_PREFIX}/opt/httpd/lib/httpd/modules/mod_authz_host.so"
        LoadModule dir_module "#{HOMEBREW_PREFIX}/opt/httpd/lib/httpd/modules/mod_dir.so"
        
        ServerName localhost
        ServerRoot "#{HOMEBREW_PREFIX}/opt/httpd"
        
        <IfModule dir_module>
            DirectoryIndex index.php index.html
        </IfModule>
      CONF
    end

    # Nginx main configuration
    nginx_includes = PORTS[:nginx].map { |port| "include #{@config_dir}/nginx_#{port}.conf;" }.join("\n  ")
    (@config_dir / "nginx_main.conf").write <<~CONF
      events {
        worker_connections 1024;
      }
      http {
        include #{HOMEBREW_PREFIX}/etc/nginx/mime.types;
        default_type application/octet-stream;

        sendfile on;
        keepalive_timeout 65;

        #{nginx_includes}
      }
    CONF
  end

  def write_env_script
    # PATH の追加とエイリアスの設定
    paths = ["#{HOMEBREW_PREFIX}/opt/php@#{LANG_VERSION}/bin"]
    aliases = []

    if ENABLED_DATABASES[:mysql]
      paths << "#{HOMEBREW_PREFIX}/opt/mysql@8.0/bin"
      aliases << "alias mysql=\"#{HOMEBREW_PREFIX}/opt/mysql@8.0/bin/mysql\""
      PORTS[:mysql].each do |port|
        aliases << "alias mysql@#{port}=\"#{HOMEBREW_PREFIX}/opt/mysql@8.0/bin/mysql --defaults-file=#{@config_dir}/my_#{port}.cnf -h 127.0.0.1\""
      end
    end

    if ENABLED_DATABASES[:postgresql]
      paths << "#{HOMEBREW_PREFIX}/opt/postgresql@15/bin"
      aliases << "alias psql=\"#{HOMEBREW_PREFIX}/opt/postgresql@15/bin/psql\""
      PORTS[:postgresql].each do |port|
        aliases << "alias psql@#{port}=\"#{HOMEBREW_PREFIX}/opt/postgresql@15/bin/psql -p #{port}\""
      end
    end

    paths += [
      "#{HOMEBREW_PREFIX}/opt/redis/bin",
      "#{HOMEBREW_PREFIX}/opt/memcached/bin",
      "#{HOMEBREW_PREFIX}/opt/nginx/bin",
      "#{HOMEBREW_PREFIX}/opt/httpd/bin",
      "#{HOMEBREW_PREFIX}/opt/node/bin"
    ]

    (@script_dir / "env.sh").write <<~SCRIPT
      #!/bin/bash
      export PATH="#{paths.join(":")}:$PATH"
      export PHP_INI_SCAN_DIR="#{@config_dir}"
      
      # Aliases
      alias php="#{HOMEBREW_PREFIX}/opt/php@#{LANG_VERSION}/bin/php -c #{@config_dir}/php.ini"
      #{aliases.join("\n    ")}
    SCRIPT

    chmod "+x", @script_dir / "env.sh"
  end

  def write_manage_services_script
    service_commands = generate_service_commands

    (@script_dir / "manage_services.sh").write <<~SCRIPT
      #!/bin/bash

      function set_env() {
        source "#{@script_dir}/env.sh"
      }

      function start_services() {
        set_env
        #{service_commands[:start].join("\n        ")}
      }

      function stop_services() {
        #{service_commands[:stop].join("\n        ")}
      }

      function manage_service() {
        local action=$1
        local name=$2
        local port=$3
        local cmd=$4
        local conf=$5
        local pid_file=$6

        if [ $port -gt 0 ]; then
          if lsof -Pi :$port -sTCP:LISTEN -t > /dev/null; then
            if [ "$action" == "Starting" ]; then
              echo "[Running] $name is already running on port $port"
            elif [ "$action" == "Stopping" ]; then
              echo "$action $name running on port $port..."
              $cmd $conf
            fi
          else
            if [ "$action" == "Starting" ]; then
              echo "$action $name with custom config on port $port..."
              $cmd $conf &
              if [ -n "$pid_file" ]; then
                echo $! > $pid_file
              fi
            elif [ "$action" == "Stopping" ]; then
              echo "[Stopped] $name service already stopped on port $port"
            fi
          fi
        fi
      }

      case "$1" in
        env)
          set_env
          ;;
        start)
          start_services
          ;;
        stop)
          stop_services
          ;;
        *)
          echo "Home: #{@project_dir}"
          echo "Usage: {source} #{PROJECT_NAME} {env|start|stop}"
          echo "Commands:"
          echo "  source #{PROJECT_NAME} env  - Set the environment variables for the project."
          echo "  #{PROJECT_NAME} start       - Start the project services."
          echo "  #{PROJECT_NAME} stop        - Stop the project services."
          exit 1
          ;;
      esac
    SCRIPT

    chmod "+x", @script_dir / "manage_services.sh"
  end

  def generate_service_commands
    commands = { start: [], stop: [] }

    # PHP-FPM
    PORTS[:php].each do |port|
      commands[:start] << "manage_service 'Starting' 'php-fpm' #{port} '#{HOMEBREW_PREFIX}/opt/php@#{LANG_VERSION}/sbin/php-fpm' '-y #{@config_dir}/php-fpm_#{port}.conf -c #{@config_dir}/php.ini' ''"
      commands[:stop] << "manage_service 'Stopping' 'php-fpm' #{port} 'pkill' '-f php-fpm' ''"
    end

    # MySQL
    if ENABLED_DATABASES[:mysql]
      PORTS[:mysql].each do |port|
        commands[:start] << "manage_service 'Starting' 'mysql' #{port} '#{HOMEBREW_PREFIX}/opt/mysql@8.0/bin/mysqld_safe' '--defaults-file=#{@config_dir}/my_#{port}.cnf' ''"
        commands[:stop] << "manage_service 'Stopping' 'mysql' #{port} '#{HOMEBREW_PREFIX}/opt/mysql@8.0/bin/mysqladmin' '--defaults-file=#{@config_dir}/my_#{port}.cnf -uroot -h 127.0.0.1 --port #{port} shutdown' ''"
      end
    end

    # PostgreSQL
    if ENABLED_DATABASES[:postgresql]
      PORTS[:postgresql].each do |port|
        commands[:start] << "manage_service 'Starting' 'postgresql' #{port} '#{HOMEBREW_PREFIX}/opt/postgresql@15/bin/pg_ctl' '-D #{@project_dir}/postgresql_#{port} start' ''"
        commands[:stop] << "manage_service 'Stopping' 'postgresql' #{port} '#{HOMEBREW_PREFIX}/opt/postgresql@15/bin/pg_ctl' '-D #{@project_dir}/postgresql_#{port} stop' ''"
      end
    end

    # Redis
    PORTS[:redis].each do |port|
      commands[:start] << "manage_service 'Starting' 'redis-server' #{port} 'redis-server' '#{@config_dir}/redis_#{port}.conf' ''"
      commands[:stop] << "manage_service 'Stopping' 'redis-server' #{port} '#{HOMEBREW_PREFIX}/bin/redis-cli' 'shutdown' ''"
    end

    # Memcached
    PORTS[:memcached].each do |port|
      commands[:start] << "manage_service 'Starting' 'memcached' #{port} 'memcached' '-d -m 64 -p #{port} -u memcached -c 1024 -P /tmp/memcached_#{port}.pid' ''"
      commands[:stop] << "manage_service 'Stopping' 'memcached' #{port} 'pkill' '-f memcached' ''"
    end

    # Nginx
    commands[:start] << "manage_service \"Starting\" \"nginx\" #{PORTS[:nginx].first} \"nginx\" \"-c #{@config_dir}/nginx_main.conf\" \"\""
    commands[:stop] << "manage_service \"Stopping\" \"nginx\" #{PORTS[:nginx].first} '#{HOMEBREW_PREFIX}/bin/nginx' '-s stop' ''"

    # Apache
    PORTS[:httpd].each do |port|
      commands[:start] << "manage_service 'Starting' 'httpd' #{port} 'httpd' '-f #{@config_dir}/httpd_#{port}.conf' ''"
      commands[:stop] << "manage_service 'Stopping' 'httpd' #{port} '#{HOMEBREW_PREFIX}/bin/apachectl' '-k stop' ''"
    end

    commands
  end

  def post_install
    PHP_EXTENSIONS.each do |ext|
      ohai "Installing #{ext} extension..."
      if install_via_homebrew(ext)
        ohai "Successfully installed #{ext} via Homebrew"
      else
        ohai "Falling back to PECL installation for #{ext}..."
        install_via_pecl(ext, @config_dir / "php.ini")
      end
    end
  end

  def install_via_homebrew(ext)
    system "brew", "install", "shivammathur/extensions/#{ext}@#{LANG_VERSION}"
  rescue => e
    ohai "Homebrew installation failed: #{e.message}"
    false
  end

  def install_via_pecl(ext, ini_file)
    if system("pecl list | grep -q #{ext}")
      ohai "#{ext} is already installed via PECL."
      true
    else
      system "#{HOMEBREW_PREFIX}/opt/php@#{LANG_VERSION}/bin/pecl", "-f", ini_file, "install", ext
    end
  end

  def get_php_extensions
    extension_dir = `php-config --extension-dir`.chomp
    ext_list = PHP_EXTENSIONS.map do |ext|
      ext == "xdebug" ? "zend_extension=#{ext}.so" : "extension=#{ext}.so"
    end.join("\n")

    [ext_list, extension_dir]
  end

  def test_service(command)
    system(command)
    puts `#{command}`
  end

  test do
    assert(File.exist?("#{prefix}/script/env.sh"), "script/env.sh does not exist.")

    # Test core services
    test_service("php -v")

    # Test database services if enabled
    test_service("mysql --version") if ENABLED_DATABASES[:mysql]
    test_service("psql --version") if ENABLED_DATABASES[:postgresql]

    # Test other services
    test_service("redis-server --version")
    test_service("memcached --version")
    test_service("nginx -v")
    test_service("httpd -v")
  end
end
