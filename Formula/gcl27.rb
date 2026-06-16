class Gcl27 < Formula
  desc "GNU Common Lisp"
  homepage "https://www.gnu.org/software/gcl"
  url "git://git.sv.gnu.org/gcl.git",
      tag:      "Version_2_7_2pre28",
      revision: "50e96687183214e8b6100f24447930ede6961df8"
  version "2.7.2pre28"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/v2.7.2prehb24"
    sha256 cellar: :any, arm64_tahoe: "44ed831446668f4703d576430d1020fbfbdb28e5a170dcabb77bd7251b059525"
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
