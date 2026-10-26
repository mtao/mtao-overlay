# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2
# shellcheck shell=bash

EAPI=8

inherit desktop systemd unpacker xdg

MY_PN="${PN%-bin}"

DESCRIPTION="Ubiquiti WiFiman Desktop: network discovery, speed tests and Teleport VPN"
HOMEPAGE="https://ui.com/download/app/wifiman-desktop"
SRC_URI="https://desktop.wifiman.com/${MY_PN}-${PV}-amd64.deb"
S="${WORKDIR}"

# ubiquiti: the app/daemon; GPL-2: bundled wg, wg-quick; MIT: bundled wireguard-go
LICENSE="ubiquiti GPL-2 MIT"
SLOT="0"
KEYWORDS="~amd64"
RESTRICT="bindist mirror strip"

# Debian Depends: net-tools, iw, resolvconf, libayatana-appindicator3-1,
# libwebkit2gtk-4.1-0, libgtk-3-0. The rest are the GUI's DT_NEEDED libs
# and tools invoked by the bundled wg-quick / daemon.
RDEPEND="
	app-shells/bash
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1
	net-wireless/iw
	sys-apps/dbus
	sys-apps/iproute2
	sys-apps/net-tools
	virtual/resolvconf
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
"

QA_PREBUILT="
	usr/bin/${MY_PN}
	usr/lib/${MY_PN}/*
"

src_install() {
	# The daemon locates its .env files and bundled wg tools next to its own
	# binary, so keep the upstream /usr/lib/${MY_PN} layout intact.
	insinto "/usr/lib/${MY_PN}"
	doins "usr/lib/${MY_PN}/.env"{,.development,.staging}
	exeinto "/usr/lib/${MY_PN}"
	doexe "usr/lib/${MY_PN}/"{"${MY_PN}d",wg,wg-quick,wireguard-go,wg_report.sh}

	dobin "usr/bin/${MY_PN}"

	domenu "usr/share/applications/${MY_PN}.desktop"
	insinto "/usr/share/icons"
	doins -r "usr/share/icons/hicolor"

	# Replaces the postinst copy into /etc/systemd/system.
	systemd_dounit "usr/lib/${MY_PN}/${MY_PN}.service"
	newinitd "${FILESDIR}/${MY_PN}.initd" "${MY_PN}"
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "The GUI requires the root daemon to be running."
	elog "  systemd: systemctl enable --now ${MY_PN}.service"
	elog "  OpenRC:  rc-update add ${MY_PN} default && rc-service ${MY_PN} start"
}

pkg_postrm() {
	xdg_pkg_postrm

	# Upstream postrm deletes the log the daemon writes into its install dir.
	if [[ -z ${REPLACED_BY_VERSION} ]]; then
		rm -f "${EROOT}"/usr/lib/${MY_PN}/${MY_PN}.log
		rmdir "${EROOT}"/usr/lib/${MY_PN} 2>/dev/null
	fi
}
