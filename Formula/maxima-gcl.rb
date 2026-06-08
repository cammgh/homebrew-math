class MaximaGcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"
  
  url "https://deb.debian.org/debian/pool/main/m/maxima/maxima_5.49.0+dsfg.orig.tar.gz"
  version "5.49.0+dsfg-4"
  sha256 "6d401a4aa307cd3a5a9cadca4fa96c4ef0e24ff95a18bb6a8f803e3d2114adee"

  conflicts_with "maxima", because: "both install a 'maxima' executable"

  depends_on "cammgh/math/gcl27"

  depends_on "gnuplot"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "texinfo" => :build

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/m/maxima/maxima_5.49.0+dsfg-4.debian.tar.xz"
    sha256 "8261d8d916b6168acba394b0f74df5ee51316a75d1a57463d324f41a398db2f5"
  end


  def install
    ENV.deparallelize

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
      --enable-gcl
      --with-gcl=gcl
    ]

    system "false"
    system "./configure", *configure_args
    system "autoreconf","-ivf"
    system "make"
    system "make", "install"
  end
    test do
    assert_match "2", shell_output("#{bin}/maxima --batch-string='1+1;'")
  end
end
