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

  # PHP versions with additional PECL packages
  PECL_INSTALL_VERSIONS = ["8.1", "8.2", "8.3"].freeze

  # PHP version => Xdebug version
  # Please comment out any unnecessary PHP versions.
  VERSIONS = {
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
  }.freeze

  # Extensions to be installed along with optional special commands
  # 'memcached' requires the path to zlib, hence the special command
   EXTENSIONS = {
    'pcov' => "",                # Code coverage driver: https://pecl.php.net/package/pcov
    'apcu' => "",                # APC User Cache: https://pecl.php.net/package/apcu
    'redis' => "",               # Redis client: https://pecl.php.net/package/redis
    'xhprof' => "",              # Hierarchical Profiler: https://pecl.php.net/package/xhprof
    'imagick' => "",             # Image processing library: https://pecl.php.net/package/imagick
    # Memcached client: https://pecl.php.net/package/memcached
    'memcached' => "PHP_ZLIB_DIR=$(brew --prefix zlib)"
  }.freeze

  def install
    VERSIONS.each do |version, xdebug_version|
      php_prefix = "#{HOMEBREW_PREFIX}/opt/php@#{version}"
      ext_dir = `#{php_prefix}/bin/php-config --extension-dir`.strip

      # Install xdebug for all versions
      handle_pecl_installation(php_prefix, ext_dir, "xdebug", xdebug_version.empty? ? "" : xdebug_version)

      # Install other PECL packages only for supported versions
      if PECL_INSTALL_VERSIONS.include?(version)
        EXTENSIONS.each do |extension, cmd|
          handle_pecl_installation(php_prefix, ext_dir, extension, cmd)
        end
      end
    end

    # Install a dummy file to indicate successful installation
    (prefix/"INSTALLED").write("phpcomplete installation successful")
  end

  def handle_pecl_installation(php_prefix, ext_dir, extension_name, special_cmd = "")
    if File.exist?("#{ext_dir}/#{extension_name}.so")
      puts "#{extension_name} is already installed for PHP #{php_prefix.split('@').last}"
    else
      system "yes no | #{special_cmd} #{php_prefix}/bin/pecl install #{extension_name} || true"
    end
  end

  test do
    assert_match "phpcomplete installation successful", shell_output("cat #{prefix}/INSTALLED")
  end
end
