class Phpcomplete < Formula
  desc "Install multiple versions of PHP with XDebug and other PECL packages"
  homepage "https://www.php.net/"
  version "0.1.0"
  url "file:///dev/null"
  sha256 ""
  license "MIT"

  # Please comment on any unnecessary PHP.
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
    # PHP version with apcu, memcached, redis and xhprof pecl installation
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

    extensions = {
      'pcov' => "",
      'apcu' => "",
      'redis' => "",
      'xhprof' => "",
      'imagick' => "",
      'memcached' => "PHP_ZLIB_DIR=$(brew --prefix zlib)"
    }

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
      if pecl_install_versions.include?(version)
        extensions.each do |extension, cmd|
          handle_pecl_installation(php_prefix, ext_dir, extension, cmd)
        end
      end
    end

    # Install a dummy file to indicate successful installation
    (prefix/"dummy").write("phpcomplete installation successful")
  end

  def handle_pecl_installation(php_prefix, ext_dir, extension_name, special_cmd = "")
    if File.exist?("#{ext_dir}/#{extension_name}.so")
      system "yes no | #{special_cmd} #{php_prefix}/bin/pecl upgrade #{extension_name} || true"
    else
      system "yes no | #{special_cmd} #{php_prefix}/bin/pecl install #{extension_name} || true"
    end
  end

  test do
    # No tests, as we don't need to check the installation of every PHP version
  end
end
