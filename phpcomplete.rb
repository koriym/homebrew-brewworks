class Phpcomplete < Formula
  desc "Install multiple versions of PHP with XDebug and other PECL packages"
  homepage "https://www.php.net/"
  version "0.1.0"
  url "file:///dev/null"
  sha256 ""
  license "MIT"

  # Please comment out any unnecessary PHP versions.
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
    # PHP versions with additional PECL packages
    pecl_install_versions = ["8.1", "8.2", "8.3"]

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

    # Extensions to be installed along with optional special commands
    # 'memcached' requires the path to zlib, hence the special command
    extensions = {
      'pcov' => "",                # Code coverage driver: https://pecl.php.net/package/pcov
      'apcu' => "",                # APC User Cache: https://pecl.php.net/package/apcu
      'redis' => "",               # Redis client: https://pecl.php.net/package/redis
      'xhprof' => "",              # Hierarchical Profiler: https://pecl.php.net/package/xhprof
      'imagick' => "",             # Image processing library: https://pecl.php.net/package/imagick
                                   # Memcached client: https://pecl.php.net/package/memcached
      'memcached' => "PHP_ZLIB_DIR=$(brew --prefix zlib)"
    }

    versions.each do |version, xdebug_version|
      php_prefix = "#{HOMEBREW_PREFIX}/opt/php@#{version}"
      ext_dir = `#{php_prefix}/bin/php-config --extension-dir`.strip

      # Install xdebug for all versions
      if File.exist?("#{ext_dir}/xdebug.so")
        system "#{php_prefix}/bin/pecl upgrade xdebug || true"
      else
        xdebug = xdebug_version.empty? ? "xdebug" : "xdebug-#{xdebug_version}"
        system "#{php_prefix}/bin/pecl install #{xdebug} || true"
      end

      # Install other PECL packages only for supported versions
      if pecl_install_versions.include?(version)
        extensions.each do |extension, cmd|
          handle_pecl_installation(php_prefix, ext_dir, extension, cmd)
        end
      end
    end

    # Install a dummy file to indicate successful installation
    (prefix/"INSTALLED").write("phpcomplete installation successful")
  end

  def handle_pecl_installation(php_prefix, ext_dir, extension_name, special_cmd = "")
    command = File.exist?("#{ext_dir}/#{extension_name}.so") ? "upgrade" : "install"
    system "yes no | #{special_cmd} #{php_prefix}/bin/pecl #{command} #{extension_name} || true"
  end

  test do
    assert_match "phpcomplete installation successful", shell_output("cat #{prefix}/INSTALLED")
  end
end
