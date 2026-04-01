# Copyright 2023-2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

# NOTE: Group name inconsistency between this overlay and upstream 1Password:
#   this overlay                -> group name 'onepassword-cli'
#   upstream after-install.sh   -> group name 'onepassword-cli'
#   GURU acct-group/1password   -> group name '1password' (for desktop app)
#   upstream after-install.sh   -> group name 'onepassword' (for desktop app)
# The CLI group 'onepassword-cli' matches upstream. The desktop app group
# differs between GURU ('1password') and upstream ('onepassword'), but the
# app validates by GID not name. See gui-apps/1password ebuild for details.

EAPI=8

DESCRIPTION="The world's most-loved password manager CLI"
HOMEPAGE="https://1password.com"
SRC_URI="
amd64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${PV}/op_linux_amd64_v${PV}.zip )
arm64? ( https://cache.agilebits.com/dist/1P/op2/pkg/v${PV}/op_linux_arm64_v${PV}.zip )
"
S="${WORKDIR}"

LICENSE="all-rights-reserved"
SLOT="0"
KEYWORDS="~amd64 ~arm64"
RESTRICT="strip test bindist"

BDEPEND="app-arch/unzip"
RDEPEND="
acct-group/onepassword-cli
"
DEPEND="${RDEPEND}"

QA_FLAGS_IGNORED="usr/bin/op"

src_install() {
	dobin op
	fowners root:onepassword-cli /usr/bin/op
	fperms g+s /usr/bin/op
}
