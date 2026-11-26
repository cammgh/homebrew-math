class FricasGcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"

  url "https://deb.debian.org/debian/pool/main/f/fricas/fricas_1.3.13.orig.tar.bz2"
  version "1.3.13-3"
  sha256 "dd4d5e06db0ba4a43a5bfb64e94f6c8d4b10e68ac65a77556891a6b24af148a2"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/fricas-gcl-1.3.13-3"
    sha256 cellar: :any, arm64_tahoe: "fbf98ef6cb8075efdb68517b7243e2d520cf2cd3a740b9973a92a450fddc1f19"
    sha256 cellar: :any, tahoe:       "7399faf35d6892620aa0c3dc3e668c6afb11582b94a1599bf709671b774b5a1c"
  end

  conflicts_with "fricas", because: "both install a 'fricas' executable"

  env :std

  depends_on "cammgh/math/gcl27"

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/f/fricas/fricas_1.3.13-3.debian.tar.xz"
    sha256 "acf13b762544b1fb1deff2ab4ccb2e5e80f7f2c7d4434d6af31f7e067105e29a"
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
