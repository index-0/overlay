EAPI=8

inherit xdg cmake desktop

DESCRIPTION="Fast PlayStation 1 emulator for x86-64/AArch32/AArch64"
HOMEPAGE="https://github.com/stenzek/duckstation"

COMMIT="39e62ae948d7b123ec9a60e7cea71243b030e85a"
SRC_URI="https://github.com/stenzek/duckstation/archive/${COMMIT}.tar.gz -> ${P}.tar.gz"

KEYWORDS="~amd64"

LICENSE="GPL-3"
SLOT="0"
IUSE="+cubeb +dbus discord +egl fbdev gbm qt6 retroachievements wayland X"

REQUIRED_USE="
	?? ( fbdev gbm )
	|| ( X wayland )
	gbm? ( egl )
	wayland? ( egl )
"

BDEPEND="
	virtual/pkgconfig
	wayland? ( kde-frameworks/extra-cmake-modules )
"
DEPEND="
	>=media-libs/libsdl2-2.28.2
	cubeb? ( media-libs/cubeb )
	dbus? ( sys-apps/dbus )
	gbm? ( x11-libs/libdrm )
	qt6? (
		dev-qt/qtbase:6[gui,network,widgets]
		dev-qt/qtsvg:6
		dev-qt/qttools:6[linguist]
	)
	retroachievements? ( net-misc/curl )
	wayland? (
		dev-libs/wayland
		qt6? ( dev-qt/qtwayland:6 )
	)
	X? (
			x11-libs/libX11
			x11-libs/libXrandr
	)
"
RDEPEND="${DEPEND}"

S="${WORKDIR}/duckstation-${COMMIT}"

src_configure() {
	local mycmakeargs=(
		-DBUILD_NOGUI_FRONTEND=$(usex !qt6)
		-DBUILD_QT_FRONTEND=$(usex qt6)
		-DENABLE_CHEEVOS=$(usex retroachievements)
		-DENABLE_CUBEB=$(usex cubeb)
		-DENABLE_DISCORD_PRESENCE=$(usex discord)
		-DUSE_DBUS=$(usex dbus)
		-DUSE_DRMKMS=$(usex gbm)
		-DUSE_EGL=$(usex egl)
		-DUSE_FBDEV=$(usex fbdev)
		-DUSE_SDL2=ON
		-DUSE_WAYLAND=$(usex wayland)
		-DUSE_X11=$(usex X)
		-DBUILD_SHARED_LIBS=OFF
	)
	cmake_src_configure
}

src_install() {
	insinto /opt/${PN}
	doins -r "${BUILD_DIR}"/bin/resources/

	newicon "${BUILD_DIR}"/bin/resources/images/duck.png duckstation.png
	make_desktop_entry "${PN} %f" "DuckStation" "${PN}" "Game"
	newins "${BUILD_DIR}"/bin/duckstation-* duckstation
	dosym ../../opt/${PN}/duckstation usr/bin/duckstation
	fperms +x /opt/${PN}/duckstation

	if use qt6; then
		doins -r "${BUILD_DIR}"/bin/translations/
	fi
}
