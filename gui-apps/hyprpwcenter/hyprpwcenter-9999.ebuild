# Copyright 1999-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 xdg

DESCRIPTION="Volume management center for Hyprland"
HOMEPAGE="https://github.com/hyprwm/hyprpwcenter"

EGIT_REPO_URI="https://github.com/hyprwm/${PN}.git"

LICENSE="BSD"
SLOT="0"

RDEPEND="
	media-video/pipewire:=
	gui-libs/hyprtoolkit:=
	x11-libs/pixman
	x11-libs/libdrm
	>=gui-libs/hyprutils-0.10.2:=
"

DEPEND="${RDEPEND}"

BDEPEND="virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${PN}-fix-CFLAGS-CXXFLAGS.patch"
)

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
