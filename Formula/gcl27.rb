class Gcl27 < Formula
  desc "GNU Common Lisp"
  homepage "https://www.gnu.org/software/gcl"
  url "git://git.sv.gnu.org/gcl.git",
      tag:      "Version_2_7_2pre_homebrew28",
      revision: "add4ff03237e7a75454776ec8d9efebc3715fd1a"
  version "2.7.2prehb28"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://github.com/cammgh/homebrew-math/releases/download/gcl27-2.7.2prehb27"
    sha256 arm64_tahoe: "f2461975cb8d32c398301185824e8bf5d0d14c02b9a901a4e6eb0d7476578194"
    sha256 tahoe:       "01b209aee370a5db4d51fcc0b31f644ffcf343f612b3838ad476b92155e2d71a"
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
