class Gcl27 < Formula
  desc "GNU Common Lisp"
  homepage "https://gnu.org/software/gcl"
  url "git://git.sv.gnu.org/gcl.git",
      tag:      "Version_2_7_2pre_homebrew17", # Replace with your target version tag
      revision: "02f8c13a9c35bf4715eeb104510c00fc2cac4d78" # Replace with the exact Git commit hash
  version "2.7.2prehb17"
  license "GPL-2.0-or-later"

  bottle do
    root_url "https://localhost"
    # sha256 cellar: :any, arm64_sequoia: "all"
    # The sha256 lines for arm64_sequoia or x86_64 will be injected dynamically by CI
  end

  #depends_on "gcc"
  depends_on "gmp"
  depends_on "libx11"
  depends_on "libxext"
  depends_on "readline"
  depends_on "xorgproto"

  depends_on "make" => :build

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
