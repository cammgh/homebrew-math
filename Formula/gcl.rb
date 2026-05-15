class Gcl < Formula
  desc "GNU Common Lisp"
  homepage "https://gnu.org/software/gcl"
  
  # Pull directly from the upstream GNU Savannah repository
  url "https://git.sv.gnu.org/gcl.git",
      tag:      "Version_2_7_2pre_homebrew1", # Replace with your target version tag
      revision: "75a48718e9b750df5a62ad21b41dbfe3cbed93cf" # Replace with the exact Git commit hash

  license "GPL-2.0-or-later"

  # Core dependencies needed to compile GCL on macOS
  depends_on "gmp"
  depends_on "readline"

  def install
    # macOS-specific environment variables for stable Lisp memory mapping
    ENV.deparallelize # Complex Lisp builds usually fail with parallel make (-j)
    
    # Fix Git timestamp synchronization issues to preserve tracked configure scripts
    system "./git_touch" if File.exist?("git_touch")

    # Ensure compiler knows exactly where Homebrew handles GMP and Readline
    configure_args = %W[
      --prefix=#{prefix}
      --enable-gmp=#{Formula["gmp"].opt_prefix}
    ]

    # Handle Apple Silicon (ARM64) specific pointer/memory layout demands
#    if Hardware::CPU.arm?
#      configure_args << "--enable-ecc"
#      configure_args << "--disable-gprof"
#    end

    # Equivalent to Debian's dh_auto_configure, passing our array of variables
    system "./configure", *configure_args
    
    # Build and install into Homebrew's temporary sandbox path
    system "make"
    system "make", "install"
  end

  # The 'autopkgtest' equivalent to verify the build functions post-install
  test do
    # Verify that calling gcl launches cleanly and executes standard Lisp evaluations
    assert_match "GCL", shell_output("#{bin}/gcl --batch -eval '(format t \"~a\" \"GCL\")'")
  end
end
