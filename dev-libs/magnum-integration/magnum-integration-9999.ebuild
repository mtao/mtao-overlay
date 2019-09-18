EAPI=5

EGIT_REPO_URI="git://github.com/mosra/magnum-integration.git"

inherit cmake-utils git-r3

DESCRIPTION="Integration libraries for the Magnum C++11/C++14 graphics engine"
HOMEPAGE="https://magnum.graphics"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+eigen +glm bullet +imgui dart ovr"

RDEPEND="
	dev-libs/magnum
	eigen? ( dev-cpp/eigen )
	glm? ( media-libs/glm )
	bullet? ( sci-physics/bullet ) 
"
DEPEND="${RDEPEND}"

src_prepare() {
	if use imgui; then
		git-r3_fetch git://github.com/ocornut/imgui.git v1.70
		git-r3_checkout git://github.com/ocornut/imgui.git ${WORKDIR}/imgui
		https://github.com/ocornut/imgui/archive/v1.72b.zip
	fi
}

src_configure() {
	# general configuration
	local mycmakeargs=(
	-DCMAKE_BUILD_TYPE=Release
	$(cmake-utils_use_with eigen)
	$(cmake-utils_use_with bullet)
	$(cmake-utils_use_with dart)
	$(cmake-utils_use_with ovr)
	$(cmake-utils_use_with glm)
	$(cmake-utils_use_with imgui)
	-DIMGUI_DIR=${WORKDIR}/imgui
	-DImGui_INCLUDE_DIR=${WORKDIR}/imgui
	)

	cmake-utils_src_configure
}

# kate: replace-tabs off;
