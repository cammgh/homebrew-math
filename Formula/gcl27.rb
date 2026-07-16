class Gcl27 < Formula
  desc "GNU Common Lisp"
  homepage "https://www.gnu.org/software/gcl"
  url "git://git.sv.gnu.org/gcl.git",
      tag:      "Version_2_7_2pre_homebrew39",
      revision: "a701cf9bc91b71bf1fb53d2319b3db1aee93b93f"
  version "2.7.2prehb39"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/gcl27-2.7.2prehb39"
    sha256 arm64_tahoe: "4037e7e384a4252c8160b8912c206dc70b4281d4e98eba35d2dce086c5ac76a6"
    sha256 tahoe:       "5ec2e945b916fa5593b1173f172a836a7b5fda3ab18457a8d81d48e1cfb4f3e3"
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
