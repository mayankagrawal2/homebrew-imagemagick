require 'formula'

class Imagemagick < Formula
  homepage 'https://legacy.imagemagick.org'

  url 'https://download.imagemagick.org/ImageMagick/download/releases/ImageMagick-6.8.9-10.tar.xz'
  sha256 'cac5dda165ab603a2f56110daf41811233d93c6fdd84e94a8430e057041d8e68'

  option 'with-quantum-depth-8', 'Compile with a quantum depth of 8 bit'
  option 'with-quantum-depth-16', 'Compile with a quantum depth of 16 bit'
  option 'with-quantum-depth-32', 'Compile with a quantum depth of 32 bit'
  option 'with-perl', 'enable build/install of PerlMagick'
  option 'without-magick-plus-plus', 'disable build/install of Magick++'

  depends_on 'libtool' => :run

  depends_on 'pkg-config' => :build

  depends_on 'jpeg' => :recommended
  depends_on 'libpng' => :recommended
  depends_on 'freetype' => :recommended

  depends_on 'x11' => :optional
  depends_on 'fontconfig' => :optional
  depends_on 'libtiff' => :optional
  depends_on 'little-cms' => :optional
  depends_on 'little-cms2' => :optional
  depends_on 'jasper' => :optional
  depends_on 'libwmf' => :optional
  depends_on 'librsvg' => :optional
  depends_on 'liblqr' => :optional
  depends_on 'openexr' => :optional
  depends_on 'ghostscript' => :optional
  depends_on 'webp' => :optional

  opoo '--with-ghostscript is not recommended' if build.with? 'ghostscript'

  skip_clean :la

  def install
    args = [ "--disable-osx-universal-binary",
             "--prefix=#{prefix}",
             "--disable-dependency-tracking",
             "--enable-shared",
             "--disable-static",
             "--without-pango",
             "--with-modules",
             "--disable-openmp"]

    args << "--disable-opencl" if build.include? 'disable-opencl'
    args << "--without-gslib" if build.without? 'ghostscript'
    args << "--without-perl" if build.without? 'perl'
    args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts" if build.without? 'ghostscript'
    args << "--without-magick-plus-plus" if build.without? 'magick-plus-plus'
    args << "--enable-hdri=yes" if build.include? 'enable-hdri'

    if build.with? 'quantum-depth-32'
      quantum_depth = 32
    elsif build.with? 'quantum-depth-16'
      quantum_depth = 16
    elsif build.with? 'quantum-depth-8'
      quantum_depth = 8
    end

    args << "--with-quantum-depth=#{quantum_depth}" if quantum_depth
    args << "--with-rsvg" if build.with? 'librsvg'
    args << "--without-x" if build.without? 'x11'
    args << "--with-fontconfig=yes" if build.with? 'fontconfig'
    args << "--with-freetype=yes" if build.with? 'freetype'
    args << "--with-webp=yes" if build.include? 'webp'

    # versioned stuff in main tree is pointless for us
    inreplace 'configure', '${PACKAGE_NAME}-${PACKAGE_VERSION}', '${PACKAGE_NAME}'
    system "./configure", *args
    system "make install"
  end

  def caveats
    s = <<-EOS.undent
      For full Perl support you must install the Image::Magick module from the CPAN.
        https://metacpan.org/module/Image::Magick
      The version of the Perl module and ImageMagick itself need to be kept in sync.
      If you upgrade one, you must upgrade the other.
      For this version of ImageMagick you should install
      version #{version} of the Image::Magick Perl module.
    EOS
    s if build.with? 'perl'
  end

  test do
    system "#{bin}/identify", "/usr/share/doc/cups/images/cups.png"
  end
end
