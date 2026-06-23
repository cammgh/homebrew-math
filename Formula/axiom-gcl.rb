class AxiomGcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"

  url "https://deb.debian.org/debian/pool/main/a/axiom/axiom_20210105dp1.orig.tar.gz"
  version "20210105dp1-5"
  sha256 "8f2b1d2cf26dcefd4e794fe2545982e4bc987b10a1945f70bd9f816df532ee17"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/axiom-gcl-20210105dp1-5"
    sha256 cellar: :any, arm64_tahoe: "52a8d797f3cd1efd8a1dc18c19fc724d68428c96e1ad0dccb71db602fc322bf2"
    sha256 cellar: :any, tahoe:       "4f8f678bab9adea1eb0c9390cbda1c85d54ea94f164fccfb9d012133efdaebde"
  end

  #conflicts_with "axiom", because: "both install a 'axiom' executable"

  env :std

  depends_on "cammgh/math/gcl27"
  depends_on "texlive"
  depends_on "gawk"  => :build
  depends_on "coreutils"  => :build
  depends_on "ghostscript"
  depends_on "libxt"
  depends_on "libxpm"
  depends_on "make" => :build
  depends_on "findutils" => :build
  #depends_on "gawk" => :build

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/a/axiom/axiom_20210105dp1-5.debian.tar.xz"
    sha256 "82c00d38c2fa406ef27b7bf2d7b605b0f96255fd1a0faf0197ea69df3fcfcdf9"
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

    #ENV.deparallelize
    ENV.append "CFLAGS","-DSIGCLD=SIGCHLD -I#{buildpath}/include"
    ENV.append "CPPFLAGS","-DSIGCLD=SIGCHLD -I#{buildpath}/include"
    ENV.append "C_INCLUDE_PATH","#{buildpath}/include"
    ENV.append "DEB_BUILD_OPTIONS","parallel=#{ENV.make_jobs}"
    ENV.prepend_path "PATH", Formula["findutils"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", buildpath/"bin"
    
    #system "false"
    system <<~SHELL
           mkdir bin include
           echo "#include <stdlib.h>" >include/malloc.h
           for i in testdir testroot prep installdirs; do
               ln -s /usr/bin/true bin/dh_$i
           done
           ln -s $(which gcl) bin/gcl27
           sed -i '' 's/mem_value(x ,i)object x;int i;/mem_value(object x,int i)/g' src/interp/vmlisp.lisp.pamphlet
           sed -i '' 's/MYHASH(s)/MYHASH(char *s)/g' src/interp/cfuns.lisp.pamphlet
           sed -i '' 's/"char \\*s;\"//g' src/interp/cfuns.lisp.pamphlet
           sed -i '' 's/MYCOMBINE(i,j)/MYCOMBINE(int i,int j)/g' src/interp/cfuns.lisp.pamphlet
           sed -i '' 's/"int i,j;\"//g' src/interp/cfuns.lisp.pamphlet
           sed -i '' 's/"unsigned int i,j;\"//g' src/interp/cfuns.lisp.pamphlet
           sed -i '' "s,-L/usr/X11R6/lib ,-L/usr/X11R6/lib -L$(brew --prefix)/lib ,g" Makefile.pamphlet
           gmake -f debian/rules -O configure
           gmake -f debian/rules -O build
           cp mnt/linux/bin/axiom int/sman
           AXIOM=$(pwd)/mnt/linux make install DESTDIR="#{prefix}"
    SHELL
  end
  test do
    output = shell_output("echo ')quit' | #{prefix}/mnt/linux/bin/axiom -noht -noclef")
    assert_match "Axiom", output
  end
end
