class FricasGcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"

  url "https://deb.debian.org/debian/pool/main/f/fricas/fricas_1.3.12.orig.tar.bz2"
  version "1.3.12-2"
  sha256 "33201f9f56c20b1266d38f5290efe7486a38422ea90f707f0345f6a589e31c8d"

  conflicts_with "fricas", because: "both install a 'fricas' executable"

  depends_on "cammgh/math/gcl27"

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/f/fricas/fricas_1.3.12-2.debian.tar.xz"
    sha256 "8210d02714d58e365e18067153ff219c1e5e672726776947786f2b49f603d0c0"
  end

  def install
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

    gcl_bin = "/opt/homebrew/bin/gcl"
    configure_args = %W[
      --prefix=#{prefix}
      --with-lisp=#{gcl_bin}
    ]

    system "./configure", *configure_args
    system "make"
    system "make", "install"
  end
    test do
    system "make","-C","src/input","check"
  end
end
