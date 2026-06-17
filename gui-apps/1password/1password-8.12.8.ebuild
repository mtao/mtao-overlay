# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature xdg

DESCRIPTION="Password Manager"
HOMEPAGE="https://1password.com"
SRC_URI="
	amd64? ( https://downloads.1password.com/linux/tar/stable/x86_64/${P}.x64.tar.gz -> ${P}-amd64.tar.gz )
	arm64? ( https://downloads.1password.com/linux/tar/stable/aarch64/${P}.arm64.tar.gz -> ${P}-arm64.tar.gz )"

S="${WORKDIR}"
LICENSE="all-rights-reserved"
SLOT="0"

KEYWORDS="~amd64 ~arm64"
RESTRICT="bindist mirror strip"

DEPEND="
	x11-misc/xdg-utils
	acct-group/onepassword
"
RDEPEND="${DEPEND}"

QA_PREBUILT="/opt/1Password/*"

src_install() {
	dodir /opt/1Password
	cp -ar "${S}/${PN}-"**"/"* "${ED}/opt/1Password/" || die "Install failed!"

	# Fill in policy kit file with a list of (the first 10) human users of
	# the system.
	dodir /usr/share/polkit-1/actions
	local policy_owners
	policy_owners="$(cut -d: -f1,3 /etc/passwd \
		| grep -E ':[0-9]{4}$' \
		| cut -d: -f1 \
		| head -n 10 \
		| sed 's/^/unix-user:/' \
		| tr '\n' ' ')"
	sed -e "s/\${POLICY_OWNERS}/${policy_owners}/" \
		"${ED}/opt/1Password/com.1password.1Password.policy.tpl" \
		> "${ED}/usr/share/polkit-1/actions/com.1password.1Password.policy" ||
		die "Failed to create policy file"

	fperms 644 /usr/share/polkit-1/actions/com.1password.1Password.policy

	dosym -r /opt/1Password/1password /usr/bin/1password
	dosym -r /opt/1Password/op-ssh-sign /usr/bin/op-ssh-sign

	domenu /opt/1Password/resources/1password.desktop
	newicon "${ED}/opt/1Password/resources/icons/hicolor/512x512/apps/1password.png" "${PN}.png"

	# Install custom_allowed_browsers example to docs and /etc
	dodoc "${ED}/opt/1Password/resources/custom_allowed_browsers"
	insinto /etc/1password
	newins "${ED}/opt/1Password/resources/custom_allowed_browsers" custom_allowed_browsers

	# chrome-sandbox requires the setuid bit to be specifically set.
	# See https://github.com/electron/electron/issues/17972
	fperms 4755 /opt/1Password/chrome-sandbox

	# Setup BrowserSupport with correct group for browser extension integration.
	# The binary hardcodes "onepassword" as the expected group name.
	# Using a different group name (e.g. "1password") causes BrowserProcessVerification
	# to fail with BinaryPermissions error.
	chgrp onepassword "${ED}/opt/1Password/1Password-BrowserSupport" || die "Failed to change group of 1Password-BrowserSupport"
	fperms g+s "/opt/1Password/1Password-BrowserSupport"
}

pkg_postinst() {
	xdg_pkg_postinst

	elog "You must add your user to the 'onepassword' group for browser integration:"
	elog "  sudo usermod -aG onepassword \$USER"
	elog "Then log out and log back in for the group change to take effect."
	elog ""
	elog "If you use a custom browser, add its binary name to:"
	elog "  /etc/1password/custom_allowed_browsers"

	optfeature "1Password CLI" app-misc/1password-cli
}
