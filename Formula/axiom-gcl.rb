class AxiomGcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"

  url "https://deb.debian.org/debian/pool/main/a/axiom/axiom_20210105dp1.orig.tar.gz"
  version "20210105dp1-4"
  sha256 "8f2b1d2cf26dcefd4e794fe2545982e4bc987b10a1945f70bd9f816df532ee17"

  #conflicts_with "axiom", because: "both install a 'axiom' executable"

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
    url "https://deb.debian.org/debian/pool/main/a/axiom/axiom_20210105dp1-4.debian.tar.xz"
    sha256 "1e1583f6e7a1493f1545796d6732d470610b7d6e84a4dfcdf1112a6cf13cd040"
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
           sed -i '' '/^$/d' src/interp/cfuns.lisp.pamphlet
           gmake -f debian/rules configure
           gmake -f debian/rules build
           gmake -f debian/rules install
           for i in debian/bin/axiom debian/bin/axiom-test; do
               sed 's,/usr/lib/axiom,#{prefix}/lib/axiom,g' $i >$i.new
               chmod +x $i.new
               mv $i.new $i
           done
           for i in debian/*.install; do
               awk '{gsub("usr/","",$2);printf("mkdir -p #{prefix}/%s && cp -r %s #{prefix}/%s\\n",$2,$1,$2)}' $i | bash -x
           done
           for i in debian/*.links; do
               awk '{gsub("usr/","",$0);printf("ln -snf #{prefix}/%s #{prefix}/%s\\n",$1,$2)}' $i | bash -x
           done
    SHELL
    #system "make","TESTSET=regresstests","GCL=/opt/homebrew/bin/gcl"
  end
  test do
    output = shell_output("echo ')quit' | #{bin}/axiom -noht -noclef")
    assert_match "Axiom", output
  end
end
