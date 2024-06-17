require "pathname"

class Brewworks < Formula
  url "file:///dev/null"
  version "1.0.0"

  ########################################################
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
  # Services not used are set to zero. (使わないサービスは0に)
  PORTS = {
    php: 9000,
    mysql: 3306,
    redis: 6379,
    memcached: 11211,
    nginx: 8080,
    httpd: 8081
  }
  PHP_EXTENSIONS = ["xdebug", "pcov", "redis", "memcached"]
  ########################################################
  DEPENDENCIES.each do |dep|
    depends_on dep
  end

  def install
    project_dir = Pathname.new(prefix)/PROJECT_NAME
    public_dir = project_dir/"public"
    log_dir = project_dir/"logs"
    php_lib_path = "/opt/homebrew/opt/php@#{PHP_VERSION}/lib/httpd/modules/libphp.so"

    (project_dir/"config").mkpath
    (project_dir/"scripts").mkpath
    public_dir.mkpath

    # ダミーファイルをpublicフォルダに配置
    (public_dir/"index.html").write <<~EOS
      <html>
        <body>
          <h1>It works!</h1>
          <p>This is a placeholder. To link your project's public directory, run:</p>
          <pre>ln -fs /full_path/to/your_project/public #{public_dir}</pre>
        </body>
      </html>
    EOS

    (project_dir/"logs/.gitkeep").write <<~EOS
    EOS

    (project_dir/"config/php-fpm.conf").write <<~EOS
      [global]
      daemonize = no
      error_log = #{log_dir}/php-fpm.log

      [www]
      listen = 127.0.0.1:#{PORTS[:php]}
      pm = dynamic
      pm.max_children = 10
      pm.start_servers = 3
      pm.min_spare_servers = 2
      pm.max_spare_servers = 4
      access.log = #{log_dir}/php-fpm-access.log
      slowlog = #{log_dir}/php-fpm-slow.log
    EOS

    (project_dir/"config/php.ini").write <<~EOS
      #{PHP_EXTENSIONS.map { |ext| "extension=#{ext}.so" }.join("\n")}
    EOS

    (project_dir/"config/my.cnf").write <<~EOS
      [mysqld]
      port=#{PORTS[:mysql]}
      socket="/tmp/mysql_#{PORTS[:mysql]}.sock"
      log-error=#{log_dir}/mysql-error.log
      general_log_file=#{log_dir}/mysql-general.log
      slow_query_log_file=#{log_dir}/mysql-slow.log
      datadir="#{project_dir}/mysql"
      pid-file="#{project_dir}/mysql/mysqld.pid"

      [client]
      port=#{PORTS[:mysql]}
      socket="/tmp/mysql_#{PORTS[:mysql]}.sock"
    EOS

    if PORTS[:redis] > 0
      (project_dir/"config/redis.conf").write <<~EOS
        port #{PORTS[:redis]}
        logfile #{log_dir}/redis.log
      EOS
    end

    if PORTS[:memcached] > 0
      (project_dir/"config/memcached.conf").write <<~EOS
        -p #{PORTS[:memcached]}
        -l 127.0.0.1
        -vv >> #{log_dir}/memcached.log 2>&1
      EOS
    end

    (project_dir/"config/nginx.conf").write <<~EOS
      server {
        listen #{PORTS[:nginx]};
        server_name localhost;
        root #{public_dir};
        index index.php index.html index.htm;

        access_log #{log_dir}/nginx-access.log;
        error_log #{log_dir}/nginx-error.log;

        location / {
          try_files $uri $uri/ /index.php?$query_string;
        }

        location ~ \.php$ {
          include #{HOMEBREW_PREFIX}/etc/nginx/fastcgi_params;
          fastcgi_pass 127.0.0.1:#{PORTS[:php]};
          fastcgi_index index.php;
          fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
      }
    EOS

    (project_dir/"config/httpd.conf").write <<~EOS
      Listen #{PORTS[:httpd]}
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

      ErrorLog #{log_dir}/httpd-error.log
      # CustomLog #{log_dir}/httpd-access.log combined

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
    EOS

    (project_dir/"config/nginx_main.conf").write <<~EOS
      events {
        worker_connections 1024;
      }
      http {
        include       #{HOMEBREW_PREFIX}/etc/nginx/mime.types;
        default_type  application/octet-stream;

        sendfile        on;
        keepalive_timeout  65;

        include #{project_dir}/config/nginx.conf;
      }
    EOS

    (project_dir/"env.sh").write <<~EOS
      #!/bin/bash
      export PATH="/opt/homebrew/opt/php@#{PHP_VERSION}/bin:/opt/homebrew/opt/mysql@#{MYSQL_VERSION}/bin:/opt/homebrew/opt/redis/bin:/opt/homebrew/opt/memcached/bin:/opt/homebrew/opt/nginx/bin:/opt/homebrew/opt/httpd/bin:/opt/homebrew/opt/node/bin:$PATH"
      export PHP_INI_SCAN_DIR="#{project_dir}/config"
      alias mysql="/opt/homebrew/opt/mysql@#{MYSQL_VERSION}/bin/mysql --defaults-file=#{project_dir}/config/my.cnf"
    EOS

    (project_dir/"scripts/manage_services.sh").write <<~EOS
      #!/bin/bash

      function set_env() {
        source "#{project_dir}/env.sh"
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

      function start_services() {
        set_env

        manage_service "Starting" "php-fpm" #{PORTS[:php]} "/opt/homebrew/opt/php@#{PHP_VERSION}/sbin/php-fpm" "-y #{project_dir}/config/php-fpm.conf -c #{project_dir}/config/php.ini" ""
        manage_service "Starting" "mysql" #{PORTS[:mysql]} "/opt/homebrew/opt/mysql@#{MYSQL_VERSION}/bin/mysqld_safe" "--defaults-file=#{project_dir}/config/my.cnf" ""
        manage_service "Starting" "redis-server" #{PORTS[:redis]} "redis-server" "#{project_dir}/config/redis.conf" ""
        manage_service "Starting" "memcached" #{PORTS[:memcached]} "memcached" "-d -m 64 -p #{PORTS[:memcached]} -u memcached -c 1024 -P /tmp/memcached_#{PORTS[:memcached]}.pid" ""
        manage_service "Starting" "nginx" #{PORTS[:nginx]} "nginx" "-c #{project_dir}/config/nginx_main.conf" ""
        manage_service "Starting" "httpd" #{PORTS[:httpd]} "httpd" "-f #{project_dir}/config/httpd.conf" ""

        echo "Services started with these settings:"
        echo "#{project_dir}/config/php-fpm.conf"
        echo "#{project_dir}/config/php.ini"
        echo "#{project_dir}/config/my.cnf"
        [ #{PORTS[:redis]} -gt 0 ] && echo "#{project_dir}/config/redis.conf"
        [ #{PORTS[:memcached]} -gt 0 ] && echo "#{project_dir}/config/memcached.conf"
        [ #{PORTS[:nginx]} -gt 0 ] && echo "#{project_dir}/config/nginx.conf"
        [ #{PORTS[:httpd]} -gt 0 ] && echo "#{project_dir}/config/httpd.conf"
        echo "The web document root: #{public_dir}"
      }

      function stop_services() {
        # php-fpm has no known 'graceful' shutdown, use pkill
        manage_service "Stopping" "php-fpm" #{PORTS[:php]} "pkill" "-f php-fpm" ""
        # Use mysqladmin for mysql shutdown
        manage_service "Stopping" "mysql" #{PORTS[:mysql]} "/opt/homebrew/opt/mysql@#{MYSQL_VERSION}/bin/mysqladmin" "--defaults-file=#{project_dir}/config/my.cnf -uroot shutdown" ""
        # Use redis-cli for redis-server shutdown
        manage_service "Stopping" "redis-server" #{PORTS[:redis]} "/opt/homebrew/bin/redis-cli" "shutdown" ""
        # memcached has no known 'graceful' shutdown, use pkill
        manage_service "Stopping" "memcached" #{PORTS[:memcached]} "pkill" "-f memcached" ""
        # nginx uses the -s stop command for a fast shutdown
        manage_service "Stopping" "nginx" #{PORTS[:nginx]} "/opt/homebrew/bin/nginx" "-s stop" ""
        # Apache can be stopped using apachectl
        manage_service "Stopping" "httpd" #{PORTS[:httpd]} "/opt/homebrew/bin/apachectl" "-k stop" ""
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
    EOS

    chmod "+x", project_dir/"env.sh"
    chmod "+x", project_dir/"scripts/manage_services.sh"

    bin.install_symlink project_dir/"scripts/manage_services.sh" => PROJECT_NAME

    # データディレクトリの初期化
    system "/opt/homebrew/opt/mysql@8.0/bin/mysqld", "--initialize-insecure", "--datadir=#{project_dir}/mysql"
  end

  def post_install
    PHP_EXTENSIONS.each do |ext|
      unless system("pecl list | grep -q #{ext}")
        system "#{HOMEBREW_PREFIX}/opt/php@#{PHP_VERSION}/bin/pecl", "install", ext
      else
        puts "#{ext} is already installed."
      end
    end
  end

  def caveats; <<~EOS
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
