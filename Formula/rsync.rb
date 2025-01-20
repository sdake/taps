class Rsync < Formula
  desc "Utility that provides fast incremental file transfer"
  homepage "https://rsync.samba.org/"
  url "https://rsync.samba.org/ftp/rsync/rsync-3.4.1.tar.gz"
  mirror "https://mirrors.kernel.org/gentoo/distfiles/rsync-3.4.1.tar.gz"
  mirror "https://www.mirrorservice.org/sites/rsync.samba.org/rsync-3.4.1.tar.gz"
  sha256 "2924bcb3a1ed8b551fc101f740b9f0fe0a202b115027647cf69850d65fd88c52"
  license "GPL-3.0-or-later"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "gcc" => :build

  depends_on "gettext"
#  depends_on "libiconv" if OS.mac?

  depends_on "lz4"
  depends_on "popt"
  depends_on "xxhash"
  depends_on "xz"
  depends_on "zlib"
  depends_on "zstd"
  depends_on "bzip2"
  depends_on "gettext"

#  depends_on "libacl"
#  uses_from_macos "zlib"


  def install
    ENV["CC"] = Formula["gcc"].opt_bin/"gcc-14"
    ENV["CXX"] = Formula["gcc"].opt_bin/"g++-14"
    ENV["OBJC"] = Formula["gcc"].opt_bin/"gcc-14"
    ENV["OBJCXX"] = Formula["gcc"].opt_bin/"g++-14"
    ENV["HOMEBREW_CC"] = Formula["gcc"].opt_bin/"gcc-14"
    ENV["HOMEBREW_CXX"] = Formula["gcc"].opt_bin/"g++-14"

    ENV["CFLAGS"] = "-I#{HOMEBREW_PREFIX}/opt/glibc/include -I#{HOMEBREW_PREFIX}/include"
    ENV["CPPFLAGS"] = "-I#{HOMEBREW_PREFIX}/opt/glibc/include -I#{HOMEBREW_PREFIX}/include"
    ENV["LDFLAGS"] = "-L#{HOMEBREW_PREFIX}/opt/glibc/lib -L#{HOMEBREW_PREFIX}/lib"

    args = [
      "--prefix=#{prefix}",
      "--with-rsyncd-conf=#{etc}/rsyncd.conf",
    ]

    system "env"
    system "bash configure.sh", *args, "--verbose" || (raise "Configure failed. Check config.log.")

    system "make"
    system "make", "install"
  end

  test do
    mkdir "a"
    mkdir "b"

    ["foo\n", "bar\n", "baz\n"].map.with_index do |s, i|
      (testpath/"a/#{i + 1}.txt").write s
    end

    system bin/"rsync", "--archive --recusive --version --times", testpath/"a/", testpath/"b/"

    (1..3).each do |i|
      assert_equal (testpath/"a/#{i}.txt").read, (testpath/"b/#{i}.txt").read
    end
  end
end
