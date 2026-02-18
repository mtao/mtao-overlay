# Copyright 2022-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

ALTERNATIVES=(
	"bin:media-gfx/blender-bin"
	"reference:media-gfx/blender"
)

inherit app-alternatives

DESCRIPTION="blender symlink"
KEYWORDS="~alpha amd64 arm arm64 ~hppa ~loong ~m68k ~mips ppc ppc64 ~riscv ~s390 ~sparc x86 ~arm64-macos ~x64-macos ~x64-solaris"
IUSE=""

RDEPEND="
"

src_install() {
	local alt=$(get_alternative)

	case ${alt} in
	bin)
		alt
		alt=bzip2-reference
		;;
	*)
		dosym "${usr_prefix}${alt}" /bin/blender
		;;
	esac

	dosym bzip2 /bin/bunzip2
	dosym ${alt} /usr/bin/blender
}
