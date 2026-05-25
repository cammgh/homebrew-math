class FricasGcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"

  url "https://deb.debian.org/debian/pool/main/a/axiom/axiom_20210105dp1.orig.tar.gz"
  version "20210105dp1-3"
  sha256 "8f2b1d2cf26dcefd4e794fe2545982e4bc987b10a1945f70bd9f816df532ee17"

  #conflicts_with "axiom", because: "both install a 'axiom' executable"

  depends_on "cammgh/math/gcl27"

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/a/axiom/axiom_20210105dp1-3.debian.tar.xz"
    sha256 "e6b3a85b39074cb8c53be71820870352baef92456e5226c89fb15a11ef9353ba"
  end

  def install
    ENV["AXIOM"] = "#{buildpath}/mnt/linux"
    ENV["PATH"] = "#{ENV["AXIOM"]}/bin:#{ENV["PATH"]}"
    ENV["GCL_ANSI"]="t"
    ENV["GCL_MULTIPROCESS_MEMORY_POOL"] = buildpath.to_s
    ENV["HOME"] = buildpath.to_s

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

    system "make","TESTSET=regresstests","GCL=gcl"
  end
  test do
    system "#{bin}/axiom", "--version"
  end
end
