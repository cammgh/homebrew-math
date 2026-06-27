class Gcl27 < Formula
  desc "GNU Common Lisp"
  homepage "https://www.gnu.org/software/gcl"
  url "git://git.sv.gnu.org/gcl.git",
      tag:      "Version_2_7_2pre32b",
      revision: "a2e9a59c9958fffc7d4a679b0d26a9f092b16afa"
  version "2.7.2pre32b"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/gcl27-2.7.2pre32b"
    sha256 arm64_tahoe: "ddce2d3d5453acfddb2cbea798f308c1bfa44b50e777039ca50afa6fbcd13b8a"
    sha256 tahoe:       "589d8568e9bee5f6c95cb61c6703eed33ead62842d0e6405c47498454d4a81d9"
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
