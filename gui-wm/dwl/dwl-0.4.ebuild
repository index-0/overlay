# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit savedconfig

DESCRIPTION="dwl is a compact, hackable compositor for Wayland based on wlroots."
HOMEPAGE="https://github.com/djpohly/dwl"

SRC_URI="https://github.com/djpohly/${PN}/archive/v${PV}/${PN}-v${PV}.tar.gz -> ${P}.tar.gz"
KEYWORDS="~amd64 ~arm64 ~loong ~ppc64 ~riscv ~x86"
S="${WORKDIR}/${PN}-${PV}"

LICENSE="GPL-3"
SLOT="0"
IUSE="X savedconfig"

DEPEND="
	>=dev-libs/wayland-1.20.0
	gui-libs/wlroots[X?]
	X? (
		x11-base/xwayland
	)
"
RDEPEND="
	${DEPEND}
"
BDEPEND="
	>=dev-libs/wayland-protocols-1.24
	>=dev-util/meson-0.60.0
	virtual/pkgconfig
"
src_prepare() {
	default

	if use X; then
		sed -i \
			-e "/XWAYLAND/s/^#//g" \
			-e "/XLIBS/s/^#//g" \
		config.mk || die
	fi

	restore_config config.h
}

src_install() {
	make DESTDIR="${D}" PREFIX="${EPREFIX}/usr" install

	save_config config.h
}
