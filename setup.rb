require "pathname"

class Setup < Formula
  desc "Installs project-specific dependencies with custom settings"
  version "1.0.0"
  url "file:///dev/null"  # ダミーのURL

  ########################################################
  # Change the following settings
  PROJECT_NAME = "myproject"
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
    php: 9001,
    mysql: 3307,
    redis: 6379,
    memcached: 11211,
    nginx: 8080,
    apache: 8081
  }
  PHP_EXTENSIONS = ["xdebug", "pcov"]
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
    log_dir.mkpath

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
      log-error=#{log_dir}/mysql-error.log
      general_log_file=#{log_dir}/mysql-general.log
      slow_query_log_file=#{log_dir}/mysql-slow.log
    EOS

    if PORTS[:redis] > 0
      (project_dir/"config/redis.conf").write <<~EOS
        port #{PORTS[:redis]}
        logfile #{log_dir}/redis.log
      EOS
    end

    (project_dir/"config/memcached.conf").write <<~EOS
      -p #{PORTS[:memcached]}
      -l 127.0.0.1
      -vv >> #{log_dir}/memcached.log 2>&1
    EOS

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
      Listen #{PORTS[:apache]}
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
    EOS

    (project_dir/"scripts/manage_services.sh").write <<~EOS
      #!/bin/bash

      function set_env() {
        source "#{project_dir}/env.sh"
      }

      function start_services() {
        set_env

        if pgrep -f "php-fpm" > /dev/null; then
          echo "php-fpm is already running"
        else
          if [ #{PORTS[:php]} -gt 0 ]; then
            echo "Starting php-fpm with custom config..."
            php-fpm -y #{project_dir}/config/php-fpm.conf -c #{project_dir}/config/php.ini &
          fi
        fi

        if pgrep -f "mysqld" > /dev/null; then
          echo "mysql is already running"
        else
          if [ #{PORTS[:mysql]} -gt 0 ]; then
            echo "Starting mysql with custom config..."
            mysqld --defaults-file=#{project_dir}/config/my.cnf &
          fi
        fi

        if pgrep -f "redis-server" > /dev/null; then
          echo "redis-server is already running"
        else
          if [ #{PORTS[:redis]} -gt 0 ]; then
            echo "Starting redis with custom config..."
            redis-server #{project_dir}/config/redis.conf &
          fi
        fi

        if pgrep -f "memcached" > /dev/null; then
          echo "memcached is already running"
        else
          if [ #{PORTS[:memcached]} -gt 0 ]; then
            echo "Starting memcached with custom config..."
            memcached -d -m 64 -p #{PORTS[:memcached]} -u memcached -c 1024 -P /tmp/memcached.pid &
          fi
        fi

        if pgrep -f "nginx" > /dev/null; then
          echo "nginx is already running"
        else
          if [ #{PORTS[:nginx]} -gt 0 ]; then
            echo "Starting nginx with custom config..."
            nginx -c #{project_dir}/config/nginx_main.conf &
          fi
        fi

        if pgrep -f "httpd" > /dev/null; then
          echo "httpd is already running"
        else
          if [ #{PORTS[:apache]} -gt 0 ]; then
            echo "Starting httpd with custom config..."
            httpd -f #{project_dir}/config/httpd.conf &
          fi
        fi

        echo "Services started. Please configure the following files as needed:"
        echo "#{project_dir}/config/php-fpm.conf"
        echo "#{project_dir}/config/php.ini"
        echo "#{project_dir}/config/my.cnf"
        if [ #{PORTS[:redis]} > 0 ]; then
          echo "#{project_dir}/config/redis.conf"
        fi
        echo "#{project_dir}/config/memcached.conf"
        echo "#{project_dir}/config/nginx.conf"
        echo "#{project_dir}/config/httpd.conf"
        echo "Ensure the web document root is set correctly in #{public_dir}"
      }

      function stop_services() {
        if [ #{PORTS[:php]} -gt 0 ]; then
          pkill -f "php-fpm"
        fi
        if [ #{PORTS[:mysql]} -gt 0 ]; then
          mysqladmin shutdown
        fi
        if [ #{PORTS[:redis]} -gt 0 ]; then
          pkill -f "redis-server"
        fi
        if [ #{PORTS[:memcached]} -gt 0 ]; then
          pkill -f "memcached"
        fi
        if [ #{PORTS[:nginx]} -gt 0 ]; then
          pkill -f "nginx"
        fi
        if [ #{PORTS[:apache]} -gt 0 ]; then
          pkill -f "httpd"
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
          echo "Usage: #{PROJECT_NAME} {env|start|stop}"
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

    # Show Usage
    system project_dir/"scripts/manage_services.sh"
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
    To manage the services, run:
      #{PROJECT_NAME} env
      #{PROJECT_NAME} start
      #{PROJECT_NAME} stop

    Configuration files are located in:
      #{prefix}/#{PROJECT_NAME}/config/
      Please edit these files as needed.

    Log files are located in:
      #{prefix}/#{PROJECT_NAME}/logs/

    Web document Root is located in:
      #{prefix}/#{PROJECT_NAME}/public
EOS
  end

  test do
    if PORTS[:php] > 0
      system "#{bin}/php", "-v"
    end
    if PORTS[:mysql] > 0
      system "#{bin}/mysql", "--version"
    end
    if PORTS[:redis] > 0
      system "#{bin}/redis-server", "--version"
    end
    if PORTS[:memcached] > 0
      system "#{bin}/memcached", "-h"
    end
    if PORTS[:nginx] > 0
      system "#{bin}/nginx", "-v"
    end
    if PORTS[:httpd] > 0
      system "#{bin}/httpd", "-v"
    end
    if PORTS[:node] > 0
      system "#{bin}/node", "--version"
    end
  end
end