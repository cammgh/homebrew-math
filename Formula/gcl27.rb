class Gcl27 < Formula
  desc "GNU Common Lisp"
  homepage "https://www.gnu.org/software/gcl"
  url "git://git.sv.gnu.org/gcl.git",
      tag:      "Version_2_7_2pre_homebrew33",
      revision: "0e8107e97fe6fdd972986c6eaef22425d807c12c"
  version "2.7.2prehb33"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/gcl27-2.7.2prehb32"
    sha256 arm64_tahoe: "47d265f9e3842318534838cb2437d7d8f1470c077b2fa9dd23f3e5aa5e729774"
    sha256 tahoe:       "67139a6fd4fea1b18165e32bd469e0f7362ef64386cb6cf7d635634d7800b583"
  end

  #depends_on "gcc"
  depends_on "gmp"
  depends_on "libx11"
  depends_on "libxext"
  depends_on "readline"
  depends_on "xorgproto"

  depends_on "make" => :build
  depends_on "texinfo" => :build
  depends_on "autoconf" => :build
  depends_on "automake" => :build

  def install
    system <<~SHELL
           autoreconf
           ./configure --prefix=#{prefix} --with-lispdir=#{elisp}
           GCL_MULTIPROCESS_MEMORY_POOL=$(pwd) gmake -O
           gmake sb_ansi-tests/test_results
           gmake sb_bench/timing_results
           gmake install
    SHELL
  end

  test do
    assert_match "GCL", shell_output("#{bin}/gcl -batch -eval '(format t \"~a\" \"GCL\")'")
  end
end
