EAPI=5

EGIT_REPO_URI="git://github.com/mosra/magnum.git"

inherit cmake-utils git-r3

DESCRIPTION="C++11/C++14 graphics middleware for games and data visualization"
HOMEPAGE="https://magnum.graphics"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+audio +glxapplication +glfwapplication +sdl2application +windowlessapplication +eglcontext +glxcontext +opengltester +anyaudioimporter +anyimageconverter +anyimageimporter +anysceneimporter +magnumfont +magnumfontconverter +objimporter +tgaimageconverter +wavaudioimporter +distancefieldconverter +imageconverter +fontconverter +gl_info +al_info"

RDEPEND="
	dev-libs/corrade
	sdl2application? ( media-libs/libsdl2 )
	glfwapplication? ( media-libs/glfw )
	al_info? ( media-libs/openal )
"
DEPEND="${RDEPEND}"

src_configure() {
	local mycmakeargs=(
		-DCMAKE_BUILD_TYPE=Release
	$(cmake-utils_use_with audio)
	$(cmake-utils_use_with glxapplication)
	$(cmake-utils_use_with glfwapplication)
	$(cmake-utils_use_with sdl2application)
	$(cmake-utils_use_with windowlessapplication)
	$(cmake-utils_use_with eglcontext)
	$(cmake-utils_use_with glxcontext)
	$(cmake-utils_use_with opengltester)
	$(cmake-utils_use_with anyaudioimporter)
	$(cmake-utils_use_with anyimageconverter)
	$(cmake-utils_use_with anyimageimporter)
	$(cmake-utils_use_with anysceneimporter)
	$(cmake-utils_use_with magnumfont)
	$(cmake-utils_use_with magnumfontconverter)
	$(cmake-utils_use_with objimporter)
	$(cmake-utils_use_with tgaimageconverter)
	$(cmake-utils_use_with wavaudioimporter)
	$(cmake-utils_use_with distancefieldconverter)
	$(cmake-utils_use_with imageconverter)
	$(cmake-utils_use_with fontconverter)
	$(cmake-utils_use_with gl_info)
	$(cmake-utils_use_with al_info)
	)
	cmake-utils_src_configure
}

# kate: replace-tabs off;
