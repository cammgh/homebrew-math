class MaximaGcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"
  
  url "https://deb.debian.org/debian/pool/main/m/maxima/maxima_5.50.0.orig.tar.gz"
  version "5.50.0-1"
  sha256 "0bc4b5e11fe153ef20b24a3a816b668ece5378cc738fa24ca426b62fd6d8fc37"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/maxima-gcl-5.50.0-1"
    sha256 arm64_tahoe: "0862f5185c910af65492207abc6a3141edad1a4ba92ec9b4a11c7055ee1c7d75"
    sha256 tahoe:       "99c064e16da798b91ae5b12c3c7f170f2278bf8331766509df81a33594dd5213"
  end

  conflicts_with "maxima", because: "both install a 'maxima' executable"

  env :std

  depends_on "cammgh/math/gcl27"

  depends_on "gnuplot"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "texinfo" => :build

  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/m/maxima/maxima_5.50.0-1.debian.tar.xz"
    sha256 "17eb76653269797147518cf03a7801aeac120794991c31af39259376fe43c167"
  end

  patch :DATA

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

    #system "false"
    system "autoreconf","-ivf"
    system <<~SHELL
           mkdir bin || true
           echo "(progn (setq si::*optimize-maximum-pages* nil)(when (fboundp (quote si::sgc-on)) (fmakunbound (quote si::sgc-on)))(si::save-system \\"bin/gcl\\"))" | gcl
           ./configure --prefix=#{prefix} --enable-gcl --with-gcl=$(pwd)/bin/gcl
           make
           echo ":lisp (setq maxima::*maxima-started* nil si::*optimize-maximum-pages* t maxima::*maxima-index-dir* \\"#{prefix}/share/info/\\" si::*readline-prefix* \\"MAXIMA::\$\$\\" si::*allow-gzipped-file* t)(si::gbc t)(si::save-system \\"foo\\")" | ./maxima-local && mv foo src/binary-gcl/maxima
           make install
    SHELL
  end
    test do
    assert_match "2", shell_output("#{bin}/maxima --batch-string='1+1;'")
  end
end

__END__
--- a/src/defint.lisp
+++ b/src/defint.lisp1
@@ -1444,10 +1444,10 @@
 
 
 (defun evenfn (e ivar)
-  (let ((temp (m+ (m- e)
-		  (cond ((atom ivar)
-			 ($substitute (m- ivar) ivar e))
-			(t ($ratsubst (m- ivar) ivar e))))))
+  (let* ((a (atom ivar))
+        (s (when a ($substitute (m- ivar) ivar e)))
+        (r (unless a ($ratsubst (m- ivar) ivar e)))
+        (temp (m+ (m- e) (if a s r))))
     (cond ((zerop1 temp)
 	   t)
 	  ((zerop1 (sratsimp temp))
@@ -1455,9 +1455,10 @@
 	  (t nil))))
 
 (defun oddfn (e ivar)
-  (let ((temp (m+ e (cond ((atom ivar)
-			   ($substitute (m- ivar) ivar e))
-			  (t ($ratsubst (m- ivar) ivar e))))))
+  (let* ((a (atom ivar))
+        (s (when a ($substitute (m- ivar) ivar e)))
+        (r (unless a ($ratsubst (m- ivar) ivar e)))
+        (temp (m+ e (if a s r))))
     (cond ((zerop1 temp)
 	   t)
 	  ((zerop1 (sratsimp temp))
