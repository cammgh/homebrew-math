class FricasGcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"

  url "https://deb.debian.org/debian/pool/main/f/fricas/fricas_1.3.13.orig.tar.bz2"
  version "1.3.13-1"
  sha256 "dd4d5e06db0ba4a43a5bfb64e94f6c8d4b10e68ac65a77556891a6b24af148a2"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/fricas-gcl-1.3.13-1"
    sha256 cellar: :any, arm64_tahoe: "7503f23ba62fb7086515f3e1d93c156e4dcc2ef3324a88f4bf5d050c645cfd61"
    sha256 cellar: :any, tahoe:       "83122896c7c9746514d21faba40e9c4f78643c163cf833c4ccac81d2e35262d2"
  end

  conflicts_with "fricas", because: "both install a 'fricas' executable"

  env :std

  depends_on "cammgh/math/gcl27"

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/f/fricas/fricas_1.3.13-1.debian.tar.xz"
    sha256 "09523ba9702ed6b613868c7a6d8036e1aa0db767ec9bcb4b96cdda6776b6bca6"
  end

  def install
    #ENV.deparallelize
    ENV["GCL_MULTIPROCESS_MEMORY_POOL"] = buildpath

    (buildpath/"debian").mkdir

    resource("debian-patches").stage do
      cp_r ".", buildpath/"debian"
    end

    series_file = buildpath/"debian/patches/series"
    if series_file.exist?
      series_file.each_line do |line|
        patch_name = line.strip
        next if patch_name.empty? || patch_name.start_with?("#")

        patch_path = buildpath/"debian/patches"/patch_name
        if patch_path.exist?
          opoo "Applying Debian upstream patch: #{patch_name}"
          system "patch", "-p1", "-i", patch_path
        end
      end
    end

    configure_args = %W[
      --prefix=#{prefix}
      --with-lisp=gcl
    ]

    system "./configure", *configure_args
    system "make"
    system "make","-C","src/input","check"
    system "make", "install"
  end
  test do
    system "#{bin}/fricas", "--version"
  end
end
