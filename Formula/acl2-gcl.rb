class Acl2Gcl < Formula
  desc "Computational Logic for Applicative Common Lisp"
  homepage "https://www.cs.utexas.edu/users/moore/acl2"

  url "https://deb.debian.org/debian/pool/main/a/acl2/acl2_8.7+dfsg.orig.tar.gz"
  version "8.7+dfsg-2"
  sha256 "2f396e166c041d852b5974f2fd57bed5e22c282bf397c7e917d0065cb1a68dce"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/v8.6+dfsg-3"
    sha256 cellar: :any, arm64_tahoe: "0e80c21b535a196e45a8b54b681a007dcb006e12e6117d2db67e5750c971e460"
    sha256 cellar: :any, tahoe:       "f934d9003399ec155331972e8a62b1f805a564a6bb349a2b153f94841d3b92a4"
  end

  #conflicts_with "acl2", because: "both install a 'acl2' executable"

  env :std

  depends_on "cammgh/math/gcl27"
  depends_on "texlive"
  depends_on "gawk"  => :build
  depends_on "coreutils"  => :build
  depends_on "make" => :build
  depends_on "findutils" => :build

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/a/acl2/acl2_8.7+dfsg-2.debian.tar.xz"
    sha256 "2e02df6148679e2efc60510c698bf41bd44681fb6a740f581f21e94c5bd2eefa"
  end

  def install
    ENV.append "DEB_BUILD_OPTIONS","parallel=#{ENV.make_jobs}"
    ENV.prepend_path "PATH", Formula["findutils"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", Formula["coreutils"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", buildpath/"bin"

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

      #system "false"
      system <<~SHELL
           for i in testdir testroot prep installdirs; do
               ln -s /usr/bin/true bin/dh_$i
           done
           echo "for i in debian/*.install; do awk -v  p=\\${i%.install} '{\\$2=p \\"/\\" \\$2;printf(\\"mkdir -p %s && cp -a %s %s%c\\",\\$2,\\$1,\\$2,10)}' \\$i |bash -x; done" >bin/dh_install
           chmod +x bin/dh_install
           echo "for i in debian/*.links; do awk -v  p=\\${i%.links} '{\\$1=p \\"/\\" \\$1;\\$2=p \\"/\\" \\$2;printf(\\"mkdir -p `dirname %s` && ln -snfr %s %s%c\\",\\$2,\\$1,\\$2,10)}' \\$i |bash -x; done" >bin/dh_link
           chmod +x bin/dh_link
           echo "#+x86_64(setq compiler::*opt-three* (concatenate (quote string) compiler::*opt-three* \\" -fno-jump-tables \\"))(si::save-system \\"bin/gcl27\\")" | gcl
           #ln -s $(which gcl) bin/gcl27
           echo "#+(and gcl no-sigfpe)(ignore-errors (si::flush-floating-point-exceptions nil nil (lambda nil nil)))" >>init.lisp
           sed -i '' 's,FINALDIR="/usr/share,FINALDIR="#{prefix}/share,g' debian/rules
           sed -i '' 's,regression-fresh,regression,g' debian/rules
           gmake -O -f debian/rules debian/mini-proveall.out
           mkdir -p #{prefix}
           tar zcf #{prefix}/$HOMEBREW_ACL2_OCF .
      SHELL
    end

    if ENV["HOMEBREW_ACL2_BUILD"] == "books"
      system <<~SHELL
           tar zxf $HOMEBREW_ACL2_ICF
           gmake -O -f debian/rules debian/test.log &
           j=\$!
           (sleep 19800; ! [ -e saved_acl2.ori ] || (cat debian/test.log >>debian/test.log.all; pkill -g \$(ps -p \$j -o pgid=); rm -f debian/test.log; mv saved_acl2.ori saved_acl2)) &
           k=\$!
           wait \$j
           kill \$k
           echo diffout
           [ ! -e books/projects/acl2-in-hol/tests/diffout ] || cat books/projects/acl2-in-hol/tests/diffout
           mkdir -p #{prefix}
           tar zcf #{prefix}/$HOMEBREW_ACL2_OCF .
      SHELL
    end

    if ENV["HOMEBREW_ACL2_BUILD"] == "install"
      system <<~SHELL
           tar zxf $HOMEBREW_ACL2_ICF
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
