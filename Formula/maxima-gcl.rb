class MaximaGcl < Formula
  desc "Computer algebra system (GCL compiler backend)"
  homepage "https://sourceforge.io"
  

  # 1. Fetch the exact upstream source archive hosted by the Debian mirrors
  url "https://deb.debian.org/debian/pool/main/m/maxima/maxima_5.49.0+dsfg.orig.tar.gz"
  version "5.49.0+dsfg-4"
  sha256 "6d401a4aa307cd3a5a9cadca4fa96c4ef0e24ff95a18bb6a8f803e3d2114adee"

  # Explicitly declare binary name overlap with the standard SBCL homebrew/core package
  conflicts_with "maxima", because: "both install a 'maxima' executable"

  # Depend on your local GCL formula inside this tap
  depends_on "cammgh/math/gcl"

  # --- Required GNU Build System Tooling ---
  # Essential when patches touch configuration scripts or Makefile templates
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "texinfo" => :build

  # 2. Attach the Debian packaging directory as a separate resource download block
  resource "debian-patches" do
    url "https://deb.debian.org/debian/pool/main/m/maxima/maxima_5.49.0+dsfg-4.debian.tar.xz"
    sha256 "8261d8d916b6168acba394b0f74df5ee51316a75d1a57463d324f41a398db2f5"
  end

  def install
    # Prevent Homebrew's compiler wrapper from optimizing away lisp symbols
    ENV.deparallelize

    # 3. Create the target debian folder inside the build path
    (buildpath/"debian").mkdir

    # 3. Unpack the debian tarball resource directly inside the build sandbox
    resource("debian-patches").stage do
      # Copy the extracted debian/ folder out into the main unpacked maxima source path
      cp_r ".", buildpath/"debian"
    end

    # 4. Programmatically loop through the Debian patches series file if it exists
    series_file = buildpath/"debian/patches/series"
    if series_file.exist?
      series_file.each_line do |line|
        # Clean the string, ignore empty rows, and skip standard quilt comment annotations
        patch_name = line.strip
        next if patch_name.empty? || patch_name.start_with?("#")

        patch_path = buildpath/"debian/patches"/patch_name
        if patch_path.exist?
          opoo "Applying Debian upstream patch: #{patch_name}"
          # Execute patch at patch level -p1 matching standard dpkg/quilt behavior
          system "patch", "-p1", "-i", patch_path
        end
      end
    end

    
    # Point Maxima directly to our newly compiled GCL executable path
    gcl_bin = Formula["cammgh/math/gcl"].opt_bin/"gcl"

    # 5. Execute standard Maxima GNU Build System configuration targeting your GCL instance
    configure_args = %W[
      --prefix=#{prefix}
      --enable-gcl
      --with-gcl=#{gcl_bin}
    ]

    system "./configure", *configure_args
    system "autoreconf","-ivf"
    system "make"
    system "make", "install"
  end
    test do
    # Run a simple symbolic math calculation to ensure the GCL core image runs flawlessly
    assert_match "2", shell_output("#{bin}/maxima --batch-string='1+1;'")
    # Run a basic algebraic verification test to ensure image dumping completed safely
    test_cmd = "run_testsuite();"
    assert_match "No unexpected errors", shell_output("#{bin}/maxima --batch-string='#{test_cmd}'")
  end
end
