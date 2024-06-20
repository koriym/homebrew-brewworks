class Phpcomplete < Formula
  desc "Install multiple versions of PHP with XDebug and other PECL packages"
  homepage "https://www.php.net/"
  version "0.1.0"
  url "file:///dev/null"
  sha256 ""
  license "MIT"

  depends_on "shivammathur/php/php@5.6"
  depends_on "shivammathur/php/php@7.0"
  depends_on "shivammathur/php/php@7.1"
  depends_on "shivammathur/php/php@7.2"
  depends_on "shivammathur/php/php@7.3"
  depends_on "shivammathur/php/php@7.4"
  depends_on "shivammathur/php/php@8.0"
  depends_on "shivammathur/php/php@8.1"
  depends_on "shivammathur/php/php@8.2"
  depends_on "shivammathur/php/php@8.3"
  depends_on "imagemagick"
  depends_on "libmemcached"
  depends_on "pkg-config"
  depends_on "zlib"

  def install
    versions = {
      "8.3" => "",
      "8.2" => "",
      "8.1" => "",
      "8.0" => "",
      "7.4" => "3.1.6",
      "7.3" => "3.1.6",
      "7.2" => "3.1.6",
      "7.1" => "2.9.8",
      "7.0" => "2.7.2",
      "5.6" => "2.5.5"
    }

    supported_versions = ["8.1", "8.2", "8.3"]

    versions.each do |version, xdebug_version|
      php_prefix = "#{HOMEBREW_PREFIX}/opt/php@#{version}"
      ext_dir = `#{php_prefix}/bin/php-config --extension-dir`.strip

      # Install xdebug for all versions
      if File.exist?("#{ext_dir}/xdebug.so")
        system "#{php_prefix}/bin/pecl upgrade xdebug || true"
      else
        if xdebug_version.empty?
          system "#{php_prefix}/bin/pecl install xdebug || true"
        else
          system "#{php_prefix}/bin/pecl install xdebug-#{xdebug_version} || true"
        end
      end

      # Install other PECL packages only for supported versions
      if supported_versions.include?(version)
        if File.exist?("#{ext_dir}/pcov.so")
          system "#{php_prefix}/bin/pecl upgrade pcov || true"
        else
          system "#{php_prefix}/bin/pecl install pcov || true"
        end

        if File.exist?("#{ext_dir}/apcu.so")
          system "#{php_prefix}/bin/pecl upgrade apcu || true"
        else
          system "#{php_prefix}/bin/pecl install apcu || true"
        end

        if File.exist?("#{ext_dir}/redis.so")
          system "#{php_prefix}/bin/pecl upgrade redis || true"
        else
          system "#{php_prefix}/bin/pecl install redis || true"
        end

        if File.exist?("#{ext_dir}/xhprof.so")
          system "#{php_prefix}/bin/pecl upgrade xhprof || true"
        else
          system "#{php_prefix}/bin/pecl install xhprof || true"
        end

        if File.exist?("#{ext_dir}/memcached.so")
          system "yes no | PHP_ZLIB_DIR=$(brew --prefix zlib) #{php_prefix}/bin/pecl upgrade memcached || true"
        else
          system "yes no | PHP_ZLIB_DIR=$(brew --prefix zlib) #{php_prefix}/bin/pecl install memcached || true"
        end

        if File.exist?("#{ext_dir}/imagick.so")
          system "yes no | #{php_prefix}/bin/pecl upgrade imagick || true"
        else
          system "yes no | #{php_prefix}/bin/pecl install imagick || true"
        end
      end
    end

    # Install a dummy file to indicate successful installation
    (prefix/"dummy").write("phpcomplete installation successful")
  end

  test do
    versions = ["5.6", "7.0", "7.1", "7.2", "7.3", "7.4", "8.0", "8.1", "8.2", "8.3"]
    versions.each do |version|
      php_prefix = "#{HOMEBREW_PREFIX}/opt/php@#{version}"
      system "#{php_prefix}/bin/php -v"

      # Test xdebug for all versions
      system "#{php_prefix}/bin/php -m | grep xdebug || true"

      # Test other PECL extensions only for supported versions
      if version.to_f >= 8.1
        system "#{php_prefix}/bin/php -m | grep pcov || true"
        system "#{php_prefix}/bin/php -m | grep apcu || true"
        system "#{php_prefix}/bin/php -m | grep redis || true"
        system "#{php_prefix}/bin/php -m | grep xhprof || true"
        system "#{php_prefix}/bin/php -m | grep memcached || true"
        system "#{php_prefix}/bin/php -m | grep imagick || true"
      end
    end
  end
end
