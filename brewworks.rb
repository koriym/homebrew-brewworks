require "pathname"

class Brewworks < Formula
  url "file:///dev/null"
  version "1.0.0"

  # -- Begin Configuration Section --
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
    redis: [6379, 6380],
    memcached: [11211, 11212],
    nginx: [8080],
    httpd: [8082]
  }
  PHP_EXTENSIONS = ["xdebug", "pcov", "redis", "memcached"]
  # -- End Configuration Section --

  DEPENDENCIES.each { |dep| depends_on dep }


  def install
    project_dir = Pathname.new(prefix)/PROJECT_NAME
    script_dir = Pathname.new(prefix)/"script"
    public_dir = project_dir/"public"
    log_dir = project_dir/"logs"
    tmp_dir = project_dir/"tmp"
    config_dir = project_dir/"config"
    php_lib_path = "#{HOMEBREW_PREFIX}/opt/php@#{PHP_VERSION}/lib/httpd/modules/libphp.so"

    [public_dir, config_dir, script_dir, tmp_dir, log_dir].each(&:mkpath)
    (tmp_dir/".gitkeep").write("")
    (log_dir/".gitkeep").write("")

    (public_dir/"index.html").write <<~HTML
      <html>
        <body>
          <h1>It works!</h1>
          <p>This is a placeholder. To link your project's public directory, run:</p>
          <pre>ln -fs /full_path/to/your_project/public #{public_dir}</pre>
        </body>
      </html>
    HTML

    write_config_files(project_dir, log_dir, php_lib_path, public_dir, tmp_dir, config_dir)
    write_env_script(script_dir, config_dir)
    write_manage_services_script(script_dir, public_dir, config_dir)

    bin.install_symlink script_dir/"manage_services.sh" => PROJECT_NAME

    PORTS[:mysql].each_with_index do |port, index|
      system "#{HOMEBREW_PREFIX}/opt/mysql@#{MYSQL_VERSION}/bin/mysqld", "--initialize-insecure", "--datadir=#{project_dir}/mysql_#{index}"
    end
  end

  def write_config_files(project_dir, log_dir, php_lib_path, public_dir, tmp_dir, config_dir)
    PORTS[:php].each_with_index do |port, index|
      (config_dir/"php-fpm_#{port}.conf").write <<~CONF
        [global]
        daemonize = no
        error_log = #{log_dir}/php-fpm_#{port}.log

        [www]
        listen = 127.0.0.1:#{port}
        pm = dynamic
        pm.max_children = 10
        pm.start_servers = 3
        pm.min_spare_servers = 2
        pm.max_spare_servers = 4
        access.log = #{log_dir}/php-fpm-access_#{port}.log
        slowlog = #{log_dir}/php-fpm-slow_#{port}.log
      CONF
    end

    extension_dir = `php-config --extension-dir`.chomp
    (config_dir/"php.ini").write <<~EOS
      memory_limit = 2048M
      error_log = #{log_dir}/php-error.log
      extension_dir=#{extension_dir}
      sys_temp_dir=#{tmp_dir}
      upload_tmp_dir=#{tmp_dir}
      xdebug.output_dir=#{tmp_dir}
      #{PHP_EXTENSIONS.map { |ext| "extension=#{ext}.so" }.join("\n")}
    EOS

    PORTS[:mysql].each_with_index do |port, index|
      (config_dir/"my_#{port}.cnf").write <<~CONF
        [mysqld]
        port=#{port}
        socket=#{tmp_dir}/mysql_#{port}.sock
        log-error=#{log_dir}/mysql_#{port}_error.log
        general_log_file=#{log_dir}/mysql_#{port}_general.log
        slow_query_log_file=#{log_dir}/mysql_#{port}_slow.log
        datadir="#{project_dir}/mysql_#{index}"
        pid-file="#{project_dir}/mysql_#{index}/mysqld.pid"

        [client]
        user=root
        port=#{port}
        socket=#{tmp_dir}/mysql_#{port}.sock
        prompt=mysql@#{port}:\\d>\\_
      CONF
    end

    PORTS[:redis].each do |port|
      (config_dir/"redis_#{port}.conf").write <<~CONF
        port #{port}
        logfile #{log_dir}/redis_#{port}.log
      CONF
    end

    PORTS[:memcached].each do |port|
      (config_dir/"memcached_#{port}.conf").write <<~CONF
        -p #{port}
        -l 127.0.0.1
        -vv >> #{log_dir}/memcached_#{port}.log 2>&1
      CONF
    end

    PORTS[:nginx].each do |port|
      (config_dir/"nginx_#{port}.conf").write <<~CONF
        server {
          listen #{port};
          server_name localhost;
          root #{public_dir};
          index index.php index.html index.htm;

          access_log #{log_dir}/nginx_#{port}_access.log;
          error_log #{log_dir}/nginx_#{port}_error.log;

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

    PORTS[:httpd].each do |port|
      (config_dir/"httpd_#{port}.conf").write <<~CONF
        Listen #{port}
        DocumentRoot "#{public_dir}"
        <Directory "#{public_dir}">
          Options Indexes FollowSymLinks
          AllowOverride All
          Require all granted
        </Directory>
        LoadModule php_module #{php_lib_path}
        <FilesMatch \.php$>
          SetHandler application/x-httpd-php
        </FilesMatch>

        ErrorLog #{log_dir}/httpd_#{port}_error.log

        LoadModule mpm_prefork_module lib/httpd/modules/mod_mpm_prefork.so
        LoadModule authz_core_module lib/httpd/modules/mod_authz_core.so
        LoadModule authz_host_module lib/httpd/modules/mod_authz_host.so
        LoadModule authz_user_module lib/httpd/modules/mod_authz_user.so
        LoadModule unixd_module lib/httpd/modules/mod_unixd.so
        LoadModule dir_module lib/httpd/modules/mod_dir.so
        
        ServerName localhost
        User www
        Group www
        
        <IfModule dir_module>
            DirectoryIndex index.php index.html
        </IfModule>
      CONF
    end

    (config_dir/"nginx_main.conf").write <<~CONF
      events {
        worker_connections 1024;
      }
      http {
        include       #{HOMEBREW_PREFIX}/etc/nginx/mime.types;
        default_type  application/octet-stream;

        sendfile        on;
        keepalive_timeout  65;

        include #{config_dir}/nginx_*.conf;
      }
    CONF
  end

  def write_env_script(script_dir, config_dir)
    (script_dir/"env.sh").write <<~SCRIPT
      #!/bin/bash
      export PATH="#{HOMEBREW_PREFIX}/opt/php@#{PHP_VERSION}/bin::$PATH"
      export PATH="#{HOMEBREW_PREFIX}/opt/mysql@#{MYSQL_VERSION}/bin:\
      #{HOMEBREW_PREFIX}/opt/redis/bin:\
      #{HOMEBREW_PREFIX}/opt/memcached/bin:\
      #{HOMEBREW_PREFIX}/opt/nginx/bin:\
      #{HOMEBREW_PREFIX}/opt/httpd/bin:\
      #{HOMEBREW_PREFIX}/opt/node/bin:$PATH"
      export PHP_INI_SCAN_DIR="#{config_dir}"
      alias mysql="#{HOMEBREW_PREFIX}/opt/mysql@#{MYSQL_VERSION}/bin/mysql"
      #{PORTS[:mysql].map { |port| "alias mysql@#{port}=\"#{HOMEBREW_PREFIX}/opt/mysql@#{MYSQL_VERSION}/bin/mysql --defaults-file=#{config_dir}/my_#{port}.cnf -h 127.0.0.1"}.join("\n")}
    SCRIPT

    chmod "+x", script_dir/"env.sh"
  end

  def write_manage_services_script(script_dir, public_dir, config_dir)
    (script_dir/"manage_services.sh").write <<~SCRIPT
      #!/bin/bash

      function set_env() {
        source "#{script_dir}/env.sh"
      }

      function start_services() {
        set_env

        echo "Starting php-fpm services..."
        #{PORTS[:php].map { |port| "manage_service 'Starting' 'php-fpm' #{port} '#{HOMEBREW_PREFIX}/opt/php@#{PHP_VERSION}/sbin/php-fpm' '-y #{config_dir}/php-fpm_#{port}.conf -c #{config_dir}/php.ini' ''" }.join("\n")}
        
        echo "Starting mysql services..."
        #{PORTS[:mysql].map { |port| "manage_service 'Starting' 'mysql' #{port} '#{HOMEBREW_PREFIX}/opt/mysql@#{MYSQL_VERSION}/bin/mysqld_safe' '--defaults-file=#{config_dir}/my_#{port}.cnf' ''" }.join("\n")}
        
        echo "Starting redis services..."
        #{PORTS[:redis].map { |port| "manage_service 'Starting' 'redis-server' #{port} 'redis-server' '#{config_dir}/redis_#{port}.conf' ''" }.join("\n")}
        
        echo "Starting memcached services..."
        #{PORTS[:memcached].map { |port| "manage_service 'Starting' 'memcached' #{port} 'memcached' '-d -m 64 -p #{port} -u memcached -c 1024 -P /tmp/memcached_#{port}.pid' ''" }.join("\n")}
        
        echo "Starting nginx services..."
        #{PORTS[:nginx].map { |port| "manage_service 'Starting' 'nginx' #{port} 'nginx' '-c #{config_dir}/nginx_#{port}.conf' ''" }.join("\n")}
        
        echo "Starting httpd services..."
        #{PORTS[:httpd].map { |port| "manage_service 'Starting' 'httpd' #{port} 'httpd' '-f #{config_dir}/httpd_#{port}.conf' ''" }.join("\n")}
        
        echo "Services started with these settings:"
        #{PORTS[:php].map { |port| "echo '#{config_dir}/php-fpm_#{port}.conf'" }.join("\n")}
        echo "#{config_dir}/php.ini"
        #{PORTS[:mysql].map { |port| "echo '#{config_dir}/my_#{port}.cnf'" }.join("\n")}
        #{PORTS[:redis].map { |port| "echo '#{config_dir}/redis_#{port}.conf'" }.join("\n")}
        #{PORTS[:memcached].map { |port| "echo '#{config_dir}/memcached_#{port}.conf'" }.join("\n")}
        #{PORTS[:nginx].map { |port| "echo '#{config_dir}/nginx_#{port}.conf'" }.join("\n")}
        #{PORTS[:httpd].map { |port| "echo '#{config_dir}/httpd_#{port}.conf'" }.join("\n")}
        echo "The web document root: #{public_dir}"
      }

      function stop_services() {
        echo "Stopping php-fpm services..."
        #{PORTS[:php].map { |port| "manage_service 'Stopping' 'php-fpm' #{port} 'pkill' '-f php-fpm' ''" }.join("\n")}
        
        echo "Stopping mysql services..."
        #{PORTS[:mysql].map { |port| "manage_service 'Stopping' 'mysql' #{port} '#{HOMEBREW_PREFIX}/opt/mysql@#{MYSQL_VERSION}/bin/mysqladmin' '--defaults-file=#{config_dir}/my_#{port}.cnf -uroot shutdown' ''" }.join("\n")}
        
        echo "Stopping redis services..."
        #{PORTS[:redis].map { |port| "manage_service 'Stopping' 'redis-server' #{port} '#{HOMEBREW_PREFIX}/bin/redis-cli' 'shutdown' ''" }.join("\n")}
        
        echo "Stopping memcached services..."
        #{PORTS[:memcached].map { |port| "manage_service 'Stopping' 'memcached' #{port} 'pkill' '-f memcached' ''" }.join("\n")}
        
        echo "Stopping nginx services..."
        #{PORTS[:nginx].map { |port| "manage_service 'Stopping' 'nginx' #{port} '#{HOMEBREW_PREFIX}/bin/nginx' '-s stop' ''" }.join("\n")}
        
        echo "Stopping httpd services..."
        #{PORTS[:httpd].map { |port| "manage_service 'Stopping' 'httpd' #{port} '#{HOMEBREW_PREFIX}/bin/apachectl' '-k stop' ''" }.join("\n")}
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
              echo "$name is already running on port $port"
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
              echo "$name service already stopped on port $port"
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
          echo "Usage: {source} #{PROJECT_NAME} {env|start|stop}"
          echo "Commands:"
          echo "  source #{PROJECT_NAME} env  - Set the environment variables for the project."
          echo "  #{PROJECT_NAME} start       - Start the project services."
          echo "  #{PROJECT_NAME} stop        - Stop the project services."
          exit 1
          ;;
      esac
    SCRIPT

    chmod "+x", script_dir/"manage_services.sh"
  end

  def post_install
    config_dir = Pathname.new(prefix)/PROJECT_NAME/"config"
    ini_file = config_dir/"php.ini"
    PHP_EXTENSIONS.each do |ext|
      unless system("pecl list | grep -q #{ext}")
        system "#{HOMEBREW_PREFIX}/opt/php@#{PHP_VERSION}/bin/pecl", "-f", ini_file, "install", ext
      else
        puts "#{ext} is already installed."
      end
    end
  end

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

  def test_service(command)
    system(command)
    puts `#{command}`
  end

  test do
    test_service("php -v")
    test_service("mysql --version")
    test_service("redis-server --version")
    test_service("memcached --version")
    test_service("nginx -v")
    test_service("httpd -v")
    test_service("node --version")
  end
end
