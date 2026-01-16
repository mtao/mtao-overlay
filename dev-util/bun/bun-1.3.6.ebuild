# Copyright 2024-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# TODO: figure out how to build bun - seems to depend on stuff deprecated in
# zip 0.14 (Build.Step.Compile.no_link_obj), but when built in zip-0.13 it complains about
# Build.Graph.incremental not existing either. For now just use binary
#
# TODO: for binary select proper platform link for non-amd64 (arm?)
EAPI=8

DESCRIPTION="Bun is an all-in-one toolkit for JavaScript and TypeScript apps."
HOMEPAGE="https://bun.com"

ZIG_SLOT="0.13"
ZIG_NEEDS_LLVM=1
inherit zig

SRC_URI="!binary? ( https://github.com/oven-sh/bun/archive/refs/tags/${PN}-v${PV}.tar.gz -> bun-${PV}.tar.gz )
binary? ( https://github.com/oven-sh/bun/releases/download/${PN}-v${PV}/bun-linux-x64.zip -> bun${PV}.zip )
"

LICENSE="LGPL-2.0"
SLOT="0"
KEYWORDS="amd64"

DEPEND=""
RDEPEND=""
BDEPEND=""

IUSE="+binary man"

PATCHES=(
)

src_unpack() {
	default
	if use !binary; then
		# let normal unpack happen, move file into place, then let zig do its thing
		mv ${WORKDIR}/${PN}-${PN}-v${PV} ${WORKDIR}/${P}
		zig_src_unpack
	else
		echo ${WORKDIR}/${PN}-linux-x64 ${WORKDIR}/${P}
		mv ${WORKDIR}/${PN}-linux-x64 ${WORKDIR}/${P}
	fi
}

pkg_pretend() {
	if use !binary; then
		zig_pkg_pretend
	fi
}
pkg_setup() {
	if use !binary; then
		zig_pkg_setup
	fi
}
src_prepare() {
	if use !binary; then
		zig_src_prepare
	else
		default
	fi
}
src_compile() {
	if use !binary; then
		zig_src_compile
	fi
}
src_test() {
	if use !binary; then
		zig_src_test
	fi
}
src_install() {
	if use !binary; then
		zig_src_install
	else
		exeinto /usr/bin
		doexe bun
	fi
}
