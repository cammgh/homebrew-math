class Acl2Gcl < Formula
  desc "Computational Logic for Applicative Common Lisp"
  homepage "https://www.cs.utexas.edu/users/moore/acl2"

  url "https://deb.debian.org/debian/pool/main/a/acl2/acl2_8.6+dfsg.orig.tar.gz"
  version "8.6+dfsg-3"
  sha256 "f633ff0ad42874381b96c34b38f4612629c3c267e2c6214f9543d03a447b366e"

  #conflicts_with "acl2", because: "both install a 'acl2' executable"

  depends_on "cammgh/math/gcl27"
  depends_on "texlive"
  depends_on "gawk"  => :build
  depends_on "coreutils"  => :build
  depends_on "make" => :build
  depends_on "findutils" => :build

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/a/acl2/acl2_8.6+dfsg-3.debian.tar.xz"
    sha256 "39613319694eb435d9933bd8fa160467bbcd0c8d8e78b8dfd421284d7b529772"
  end

  def install
    ENV.append "DEB_BUILD_OPTIONS","parallel=#{ENV.make_jobs}"
    ENV.prepend_path "PATH", Formula["findutils"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", Formula["coreutils"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", buildpath/"bin"
    ENV["PF1"]="add-ons proof-builder finite-set-theory cowles defsort doc meta bdd parsers tau hints powerlists unicode ihs build arithmetic hacking intel ordinals sorting oslib proofstyles arithmetic-2 data-structures textbook nonstd arithmetic-3 xdoc defexec clause-processors make-event arithmetic-5 acl2s tools demos misc system coi models std rtl workshops centaur projects "
    ENV["PF2"]="add-ons proof-builder finite-set-theory cowles defsort doc meta bdd parsers tau hints powerlists unicode ihs build arithmetic hacking intel ordinals sorting oslib proofstyles arithmetic-2 data-structures textbook nonstd arithmetic-3 xdoc defexec clause-processors make-event arithmetic-5 acl2s tools demos misc system coi models std rtl workshops kestrel "
    ENV["PF3"]="centaur projects kestrel "

    if ENV["HOMEBREW_ACL2_BUILD"] == "core"
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

      system <<~SHELL
           for i in testdir testroot prep installdirs; do
               ln -s /usr/bin/true bin/dh_$i
           done
           echo "for i in debian/*.install; do awk -v  p=\\${i%.install} '{\\$2=p \\"/\\" \\$2;printf(\\"mkdir -p %s && cp -a %s %s\\n\\",\\$2,\\$1,\\$2)}' $i |bash -x; done" >bin/dh_install
           chmod +x bin/dh_install
           echo "for i in debian/*.links; do awk -v  p=\\${i%.links} '{\\$1=p \\"/\\" \\$1;\\$2=p \\"/\\" \\$2;printf(\\"mkdir -p `dirname %s` && ln -snfr %s %s\\n\\",\\$2,\\$1,\\$2)}' $i |bash -x; done" >bin/dh_link
           chmod +x bin/dh_link
           ln -s $(which gcl) bin/gcl27
           echo "#+(and gcl no-sigfpe)(ignore-errors (si::flush-floating-point-exceptions nil nil (lambda nil nil)))" >>init.lisp
           sed -i '' 's,FINALDIR="/usr/share,FINALDIR=#{prefix}/share,g' debian/rules
           gmake -O -f debian/rules debian/mini-proveall.out
           mkdir -p #{prefix}
           tar zcf #{prefix}/$HOMEBREW_ACL2_OCF .
      SHELL
    end

    if ENV["HOMEBREW_ACL2_BUILD"] == "books"
      if ENV["HOMEBREW_ACL2_CHUNK"]=="1"
        ENV["EXCLUDED_PREFIXES"]=ENV["PF1"]
      end
      if ENV["HOMEBREW_ACL2_CHUNK"]=="2"
        ENV["EXCLUDED_PREFIXES"]=ENV["PF2"]
      end
      if ENV["HOMEBREW_ACL2_CHUNK"]=="3"
        ENV["EXCLUDED_PREFIXES"]=ENV["PF3"]
      end
      system <<~SHELL
           tar zxf $HOMEBREW_ACL2_ICF
           rm -f debian/test.log
           gmake -O -f debian/rules debian/test.log
           touch infix-stamp build-stamp
           mkdir -p #{prefix}
           tar zcf #{prefix}/$HOMEBREW_ACL2_OCF .
      SHELL
    end

    if ENV["HOMEBREW_ACL2_BUILD"] == "install"
      system <<~SHELL
           for i in $HOMEBREW_ACL2_ICF; do
               tar zxf $i
               cat debian/test.log >>debian/test.log.all
           done
           mv debian/test.log.all debian/test.log
           touch debian/test.log infix-stamp build-stamp
           yes | gmake -f debian/rules install
           sed -i '' 's,/usr/lib/acl2,#{prefix}/lib/acl2,g' debian/acl2/usr/bin/acl2
           for i in $(find debian -type d -name usr); do mv $i/* $i/..; rmdir $i; done
           mkdir -p #{prefix}
           rm -f #{prefix}/share/acl2/tmp
           for i in debian/*.install; do j=${i%.install}; cp -a $j/* #{prefix}/; done
      SHELL
    end
  end
  test do
    output = shell_output("echo '(quit)' | #{bin}/acl2")
    assert_match "ACL2", output
  end
end
