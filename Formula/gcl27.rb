class Gcl27 < Formula
  desc "GNU Common Lisp"
  homepage "https://www.gnu.org/software/gcl"
  url "git://git.sv.gnu.org/gcl.git",
<<<<<<< HEAD
      tag:      "Version_2_7_2pre_homebrew41",
      revision: "fd137b672e690053d59c694dcb8bb20ae4821a37"
  version "2.7.2prehb41"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/gcl27-2.7.2prehb41"
    sha256 arm64_tahoe: "b886a293c95890c4b6dea6a4460e70a4ea1c43d5f869b59a83210337dcff7973"
    sha256 tahoe:       "6815717a826b721124d46ebf536b333f0b52954ed50010d007e79f2279489380"
=======
      tag:      "Version_2_7_2pre38",
      revision: "ea0fc878f4b18e16e6ae12d4f45a41d59cbec259"
  version "2.7.2pre38"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/gcl27-2.7.2pre38"
    sha256 arm64_tahoe: "55f310d8638bb7a261059473eaf793d5dfcf5fc7f3e534d03778de41f0d04ccc"
    sha256 tahoe:       "f07508795b2a95acaabe951bd60468e7151720e9683724a9ff14de41502c75bf"
>>>>>>> gcl27
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
