# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-cpp/eigen/eigen-3.1.3.ebuild,v 1.8 2014/10/29 09:34:32 ago Exp $

EAPI=5



DESCRIPTION="A simple C++ geometry processing library"
HOMEPAGE="http://libigl.github.io/libigl/"

LICENSE="MPL-2.0"
KEYWORDS="alpha amd64 ~arm ~hppa ia64 ppc ppc64 sparc x86 ~amd64-linux ~x86-linux"
SLOT="3"
IUSE="debug doc"

if [[ ${PV} = 9999 ]]; then
	inherit git-2
	EGIT_REPO_URI="https://github.com/libigl/libigl.git"
	EGIT_BRANCH="master"
else
	SRC_URI="http://github.com/libigl/${PV}.tar.bz2 -> ${P}.tar.bz2"
fi

DEPEND="doc? ( app-doc/doxygen[dot,latex] )"
RDEPEND="!dev-cpp/eigen:0"

#src_unpack() {
#	default
#	mv ${PN}* ${P} || die
#}



src_install() {
	doheader -r include/igl
	return
	cmake-utils_src_install
	if use doc; then
		cd "${CMAKE_BUILD_DIR}"/doc
		dohtml -r html/*
	fi
}
