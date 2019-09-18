# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Integration libraries for the Magnum C++11/C++14 graphics engine"
HOMEPAGE="https://magnum.graphics"
SRC_URI="https://github.com/mosra/magnum-integration/archive/master.tar.gz -> magnum-integration.tar.gz \
https://github.com/ocornut/imgui/archive/v1.72b.zip -> imgui-v1.72b.zip
"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="+eigen +glm bullet +imgui dart ovr"

DEPEND="
	dev-libs/magnum
	eigen? ( dev-cpp/eigen )
	glm? ( media-libs/glm )
	bullet? ( sci-physics/bullet ) 
	"
RDEPEND="${DEPEND}"
BDEPEND=""

src_configure() {
	# general configuration
	local mycmakeargs=(
	-DCMAKE_BUILD_TYPE=Release
	-DWITH_EIGEN=$(usex eigen)
	-DWITH_EIGEN=ON
	-DWITH_BULLET=$(usex bullet)
	-DWITH_DART=$(usex dart)
	-DWITH_OVR=$(usex ovr)
	-DWITH_GLM=$(usex glm)
	-DWITH_IMGUI=$(usex imgui)
	-DIMGUI_DIR=${WORKDIR}/imgui-1.72b
	-DImGui_INCLUDE_DIR=${WORKDIR}/imgui-1.72b
	)

	cmake-utils_src_configure
}

