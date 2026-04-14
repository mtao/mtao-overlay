# Copyright 2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit cmake-utils

DESCRIPTION="Integration libraries for the Magnum C++11/C++14 graphics engine"
HOMEPAGE="https://magnum.graphics"
SRC_URI="https://github.com/mosra/corrade/archive/v${PV}.tar.gz -> corrade-${PV}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="dev-util/cmake"
BDEPEND=""

src_configure() {
	local mycmakeargs=(
	-DCMAKE_INSTALL_PREFIX="${PREFIX}/usr"
		-DCMAKE_BUILD_TYPE=Release
	)
	cmake-utils_src_configure
}
