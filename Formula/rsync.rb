class Rsync < Formula
  desc "Utility for fast incremental file transfer"
  homepage "https://rsync.samba.org/"
  url "https://download.samba.org/pub/rsync/rsync-3.4.1.tar.gz"
  sha256 "2924bcb3a1ed8b551fc101f740b9f0fe0a202b115027647cf69850d65fd88c52"


  depends_on "gettext"         # Internationalization support
#  depends_on "libiconv"        # Character encoding
  depends_on "libiconv" if OS.mac?  # Character encoding (macOS specific)
  depends_on "libacl" if OS.linux?  # ACL support (Linux specific)
  depends_on "zlib"            # Compression library
  depends_on "popt"            # Command-line option parsing
  depends_on "lz4"             # LZ4 compression
  depends_on "zstd"            # Zstandard compression
  depends_on "bzip2"           # Bzip2 compression
  depends_on "xz"              # XZ compression
  depends_on "wolfssl"         # SSL/TLS library for secure transfers

  def install
    args = [
      "--prefix=#{prefix}",
      "--enable-acl-support",       # Enable Access Control Lists
      "--enable-xattr-support",    # Enable extended attributes
      "--enable-fileflags",        # Enable file flags
      "--enable-crtimes",          # Enable creation times
      "--enable-iconv",            # Enable character encoding conversion
      "--enable-ipv6",             # Enable IPv6 support
      "--enable-debug",            # Include debug symbols
      "--with-included-popt",      # Use included POPT library
      "--with-included-zlib",      # Use included Zlib
      "--with-wolfssl"             # Use WolfSSL for secure communication
    ]

    # Specify compression library paths
    args << "--with-lz4=#{Formula["lz4"].opt_prefix}"
    args << "--with-zstd=#{Formula["zstd"].opt_prefix}"
    args << "--with-bzip2=#{Formula["bzip2"].opt_prefix}"
    args << "--with-xz=#{Formula["xz"].opt_prefix}"

    system "./configure", *args
    system "make", "install"
  end

  test do
    # Test if the installed binary runs correctly
    assert_match version.to_s, shell_output("#{bin}/rsync --version")
    system "#{bin}/rsync", "--version"
    
  end
end
