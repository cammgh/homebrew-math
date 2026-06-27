class Gcl27 < Formula
  desc "GNU Common Lisp"
  homepage "https://www.gnu.org/software/gcl"
  url "git://git.sv.gnu.org/gcl.git",
      tag:      "Version_2_7_2pre34",
      revision: "266b96f19a404d1c68c5c1de44606a074aae0e85"
  version "2.7.2pre34"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/gcl27-2.7.2pre34"
    sha256 arm64_tahoe: "02891d24a32892c586e64670e38508ee02f0da520a92e21560819df535eb3e4c"
    sha256 tahoe:       "c69a814133ac57e633c92bf5bdf4f89a4ec22179cce7ab770a1bb87b8b6edb7a"
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
