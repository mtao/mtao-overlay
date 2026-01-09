# Copyright 2019-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit go-module

DESCRIPTION="A Git credential helper that utilizes the 1Password CLI to authenticate a Git over http(s) connection."
HOMEPAGE="https://github.com/ethrgeist/git-credential-1password"
SRC_URI="https://github.com/ethrgeist/git-credential-1password/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE=" MIT"
SLOT="0"
KEYWORDS="*"

src_compile() {
	go build -mod=vendor . || die
}

src_install() {
	dobin ${PN}
	einstalldocs
}
