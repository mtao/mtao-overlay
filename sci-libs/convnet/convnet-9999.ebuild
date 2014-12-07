# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5

inherit git-2

DESCRIPTION="ConvNet is a fast C++ based GPU implementation of Convolutional Neural Nets."
HOMEPAGE="https://github.com/TorontoDeepLearning/convnet"
EGIT_REPO_URI="https://github.com/mtao/convnet"
EGIT_BRANCH="develop"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="+opencv"

RDEPEND="sci-libs/hdf5
dev-libs/protobuf
media-libs/libjpeg-turbo
opencv? (media-libs/opencv)
"
DEPEND="${RDEPEND}"


src_configure() {
	sed -i \
		-e '/^CXX/d' \
		-e 's|^CONFIG.*|CONFIG = gentoo|' \
		-e 's|^PREFIX = .*|PREFIX = /usr|' \
		Makefile || die "sed failed"
}

src_compile() {
	emake main
	use client && emake client
	if use doc ; then
		doxygen zmqpp.doxygen.conf || die "building documentation failed"
	fi		
}

src_install() {
	# work around primitive build system
	insinto /usr/include/zmqpp
	doins src/zmqpp/*.hpp
	newlib.so build/gentoo-*/libzmqpp.so.* libzmqpp.so.${LIB_VERSION}
	dosym /usr/lib/libzmqpp.so.${LIB_VERSION} /usr/lib/libzmqpp.so
	use static-libs && dolib.a build/gentoo-*/*.a
	use client && dobin build/gentoo-*/zmqpp
	use doc && dohtml -r docs/html/*
}
