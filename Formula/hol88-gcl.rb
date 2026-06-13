class Hol88Gcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"

  url "https://deb.debian.org/debian/pool/main/h/hol88/hol88_2.02.19940316dfsg.orig.tar.gz"
  version "2.02.19940316dfsg-9"
  sha256 "8e2a4f83cea20d0cf2416f7d55c951498f6c807b03ebc9381a02fa4c81c5da69"

  #conflicts_with "hol88", because: "both install a 'hol88' executable"

  depends_on "cammgh/math/gcl27"
  depends_on "texlive"
  depends_on "gawk"  => :build
  #depends_on "coreutils"  => :build
  #depends_on "ghostscript"
  #depends_on "libxt"
  #depends_on "libxpm"
  depends_on "make" => :build
  depends_on "findutils" => :build
  #depends_on "gawk" => :build

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/h/hol88/hol88_2.02.19940316dfsg-9.debian.tar.xz"
    sha256 "8016a7c2b904406f45a58bcafe301996ef56587cf7c94f83694223c4c021c389"
  end

  def install
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

    #ENV.append "CFLAGS","-DSIGCLD=SIGCHLD -I#{buildpath}/include"
    #ENV.append "CPPFLAGS","-DSIGCLD=SIGCHLD -I#{buildpath}/include"
    #ENV.append "C_INCLUDE_PATH","#{buildpath}/include"
    #ENV.append "DEB_BUILD_OPTIONS","parallel=#{ENV.make_jobs}"
    ENV.prepend_path "PATH", Formula["findutils"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", buildpath/"bin"
    ENV.deparallelize

    #system "false"
    system <<~SHELL
           mkdir bin #include
           #echo "#include <stdlib.h>" >include/malloc.h
           for i in testdir testroot prep installdirs install; do
               ln -s /usr/bin/true bin/dh_$i
           done
           ln -s $(which gcl) bin/gcl27
           gmake -f debian/rules configure
           gmake -f debian/rules build
           mkdir -p debian/hol88/usr/bin
           touch debian/hol88/usr/bin/hol88.sh
           gmake -f debian/rules install
           for i in debian/hol88.sh; do
               sed 's,/usr/lib/hol88,#{prefix}/lib/hol88,g' $i >$i.new
               chmod +x $i.new
               mv $i.new $i
           done
           chmod +x hol
           for i in debian/*.install; do
               awk '{gsub("/?usr/","",$2);printf("mkdir -p #{prefix}/%s && cp -r %s #{prefix}/%s\\n",$2,$1,$2)}' $i | bash -x
           done
           for i in debian/*.links; do
               awk '{gsub("/?usr/","",$0);printf("mkdir -p `dirname #{prefix}/%s` && ln -snf #{prefix}/%s #{prefix}/%s\\n",$1,$2)}' $i | bash -x
           done
           mv #{prefix}/bin/hol88.sh #{prefix}/bin/hol88
    SHELL
    #system "make","TESTSET=regresstests","GCL=/opt/homebrew/bin/gcl"
  end
  test do
    output = shell_output("echo 'quit();;' | #{bin}/hol88")
    assert_match "HOL88", output
  end
end
