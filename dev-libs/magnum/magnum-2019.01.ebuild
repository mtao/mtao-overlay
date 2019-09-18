# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils
DESCRIPTION="C++11/C++14 graphics middleware for games and data visualization"
HOMEPAGE="https://magnum.graphics"
SRC_URI="https://github.com/mosra/magnum/archive/v${PV}.tar.gz -> magnum-${PV}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+audio +glxapplication +glfwapplication +sdl2application +windowlessapplication +eglcontext +glxcontext +opengltester +anyaudioimporter +anyimageconverter +anyimageimporter +anysceneimporter +magnumfont +magnumfontconverter +objimporter +tgaimageconverter +tgaiimporter +wavaudioimporter +distancefieldconverter +imageconverter +fontconverter +gl_info +al_info"

RDEPEND="
	dev-libs/corrade
	sdl2application? ( media-libs/libsdl2 )
	glfwapplication? ( media-libs/glfw )
	al_info? ( media-libs/openal )
"
RDEPEND="${DEPEND}"
BDEPEND=""


src_configure() {
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX="${EPREFIX}/usr"
		-DCMAKE_BUILD_TYPE=Release
		-DWITH_AUDIO=$(usex audio)
		-DWITH_GLXAPPLICATION=$(usex glxapplication)
		-DWITH_GLFWAPPLICATION=$(usex glfwapplication)
		-DWITH_SDL2APPLICATION=$(usex sdl2application)
		-DWITH_WINDOWLESSGLXAPPLICATION=$(usex windowlessapplication)
		-DWITH_EGLCONTEXT=$(usex eglcontext)
		-DWITH_GLXCONTEXT=$(usex glxcontext)
		-DWITH_OPENGLTESTER=$(usex opengltester)
		-DWITH_ANYAUDIOIMPORTER=$(usex anyaudioimporter)
		-DWITH_ANYIMAGECONVERTER=$(usex anyimageconverter)
		-DWITH_ANYIMAGEIMPORTER=$(usex anyimageimporter)
		-DWITH_ANYSCENEIMPORTER=$(usex anysceneimporter)
		-DWITH_MAGNUMFONT=$(usex magnumfont)
		-DWITH_MAGNUMFONTCONVERTER=$(usex magnumfontconverter)
		-DWITH_OBJIMPORTER=$(usex objimporter)
		-DWITH_TGAIMAGECONVERTER=$(usex tgaimageconverter)
		-DWITH_TGAIMPORTER=$(usex tgaiimporter)
		-DWITH_WAVAUDIOIMPORTER=$(usex wavaudioimporter)
		-DWITH_DISTANCEFIELDCONVERTER=$(usex distancefieldconverter)
		-DWITH_IMAGECONVERTER=$(usex imageconverter)
		-DWITH_FONTCONVERTER=	$(usex fontconverter)
		-DWITH_GL_INFO=$(usex gl_info)
		-DWITH_AL_INFO=$(usex al_info)
	)
	cmake-utils_src_configure
}
