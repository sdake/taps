
class Rsync < Formula
  desc "Utility that provides fast incremental file transfer"
  homepage "https://rsync.samba.org/"
  url "https://rsync.samba.org/ftp/rsync/rsync-3.4.1.tar.gz"
  mirror "https://mirrors.kernel.org/gentoo/distfiles/rsync-3.4.1.tar.gz"
  mirror "https://www.mirrorservice.org/sites/rsync.samba.org/rsync-3.4.1.tar.gz"
  sha256 "2924bcb3a1ed8b551fc101f740b9f0fe0a202b115027647cf69850d65fd88c52"
  license "GPL-3.0-or-later"

  livecheck do
    url "https://rsync.samba.org/ftp/rsync/?C=M&O=D"
    regex(/href=.*?rsync[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "lz4"
  depends_on "openssl@3"
  depends_on "popt"
  depends_on "xxhash"
  depends_on "zstd"

  uses_from_macos "zlib"

  # hfs-compression.diff has been marked by upstream as broken since 3.1.3
  # and has not been reported fixed as of 3.2.7
  patch do
    url "https://download.samba.org/pub/rsync/src/rsync-patches-3.4.1.tar.gz"
    mirror "https://www.mirrorservice.org/sites/rsync.samba.org/rsync-patches-3.4.1.tar.gz"
    sha256 "f56566e74cfa0f68337f7957d8681929f9ac4c55d3fb92aec0d743db590c9a88"
    apply "patches/fileflags.diff"
  end

  def install
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-profile
      --with-rsyncd-conf=#{etc}/rsyncd.conf
      --enable-profile
      --enable-largefile
      --enable-ipv6
      --enable-locale
      --enable-openssl
      --disable-md5-asm
      --disable-roll-asm
      --enable-xxhash
      --enable-zstd
      --enable-lz4
      --enable-iconv
      --enable-iconv-open
      --enable-acl-support
      --enable-xattr-support
      --with-included-zlib=no
    ]

    if Hardware::CPU.intel? && Hardware::CPU.is_64_bit?
      args << "--enable-roll-simd"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    mkdir "a"
    mkdir "b"

    ["foo\n", "bar\n", "baz\n"].map.with_index do |s, i|
      (testpath/"a/#{i + 1}.txt").write s
    end

    system bin/"rsync", "-artv", testpath/"a/", testpath/"b/"

    (1..3).each do |i|
      assert_equal (testpath/"a/#{i}.txt").read, (testpath/"b/#{i}.txt").read
    end
  end
end

