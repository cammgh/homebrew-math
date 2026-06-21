class Gcl27 < Formula
  desc "GNU Common Lisp"
  homepage "https://www.gnu.org/software/gcl"
  url "git://git.sv.gnu.org/gcl.git",
      tag:      "Version_2_7_2pre_homebrew26",
      revision: "9f0ed4542eabaf4f45c6760a7a95f74e8c2f0738"
  version "2.7.2prehb26"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/gcl27-2.7.2pre28"
    sha256               arm64_tahoe: "44f7100152310cd9f6900e403d098d1807f4213d9d77648bdae4ac2e09e585c1"
    sha256 cellar: :any, tahoe:       "16574669899df14d332baaee76360ae82a00ce8752d397165d1757c97e7c57cc"
  end

  #depends_on "gcc"
  depends_on "gmp"
  depends_on "libx11"
  depends_on "libxext"
  depends_on "readline"
  depends_on "xorgproto"

  depends_on "make" => :build
  depends_on "texinfo" => :build

  def install
    system <<~SHELL
           ./git_touch
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
