class Gcl < Formula
  desc "GNU Common Lisp"
  homepage "https://gnu.org/software/gcl"
  # Pull directly from the upstream GNU Savannah repository
  url "git://git.sv.gnu.org/gcl.git",
      tag:      "Vertion_2_7_2pre_homebrew2", # Replace with your target version tag
      revision: "3fc457ca07c17625cc5772caebeacbfca26d8a6a" # Replace with the exact Git commit hash
  license "GPL-2.0-or-later"

  # Explicitly ignores libx11 during strict dynamic linkage analysis checks
  ignore_linkage "libx11"

  # Core dependencies needed to compile GCL on macOS
  depends_on "gmp"
  depends_on "libX11"
  depends_on "readline"

  def install

    # 1. Establish the local, writable lockfile pool inside the temporary build sandbox
    ENV["GCL_MULTIPROCESS_MEMORY_POOL"] = buildpath

    # Fix Git timestamp synchronization issues to preserve tracked configure scripts
    system "./git_touch" if File.exist?("git_touch")

    # Ensure compiler knows exactly where Homebrew handles GMP and Readline
    configure_args = %W[
      --prefix=#{prefix}
      --enable-gmp=#{Formula["gmp"].opt_prefix}
      lispdir=#{elisp}
    ]

    # Equivalent to Debian's dh_auto_configure, passing our array of variables
    system "./configure", *configure_args

    # Build and install into Homebrew's temporary sandbox path
    system "make"
    system "make", "sb_ansi-tests/test_results"
    system "make", "sb_bench/timing_results"
    system "make", "install"

  end

  # The 'autopkgtest' equivalent to verify the build functions post-install
  test do
    # Verify that calling gcl launches cleanly and executes standard Lisp evaluations
    assert_match "GCL", shell_output("#{bin}/gcl --batch -eval '(format t \"~a\" \"GCL\")(quit)'")
  end
end
