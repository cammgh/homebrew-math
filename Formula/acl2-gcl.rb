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

    ENV.prepend_path "PATH", Formula["findutils"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", Formula["coreutils"].opt_libexec/"gnubin"
    ENV.prepend_path "PATH", buildpath/"bin"

    system "false"
    system <<~SHELL
           #mkdir bin #include
           #echo "#include <stdlib.h>" >include/malloc.h
           for i in testdir testroot prep installdirs install; do
               ln -s /usr/bin/true bin/dh_$i
           done
           ln -s $(which gcl) bin/gcl27
           echo '#+(and gcl no-sigfpe)(ignore-errors (si::flush-floating-point-exceptions nil nil (lambda nil nil)))' >>init.lisp
           #gmake -f debian/rules configure
           gmake -O -f debian/rules build
           mkdir -p debian/acl2/usr/bin
           touch debian/acl2/usr/bin/acl2.sh
           gmake -f debian/rules install
           for i in debian/acl2.sh; do
               sed 's,/usr/lib/acl2,#{prefix}/lib/acl2,g' $i >$i.new
               chmod +x $i.new
               mv $i.new $i
           done
           for i in debian/*.install; do
               awk '{gsub("/?usr/","",$2);printf("mkdir -p #{prefix}/%s && cp -r %s #{prefix}/%s\\n",$2,$1,$2)}' $i | bash -x
           done
           for i in debian/*.links; do
               awk '{gsub("/?usr/","",$0);printf("mkdir -p `dirname #{prefix}/%s` && ln -snf #{prefix}/%s #{prefix}/%s\\n",$1,$2)}' $i | bash -x
           done
           mv #{prefix}/bin/acl2.sh #{prefix}/bin/acl2
    SHELL
  end
  test do
    output = shell_output("echo '(quit)' | #{bin}/acl2")
    assert_match "ACL2", output
  end
end
