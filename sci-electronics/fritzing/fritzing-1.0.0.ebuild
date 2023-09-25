# Copyright 1999-2022 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit qmake-utils xdg

APP_COMMIT="7b75a63c264b31b9ed69481f1f2c84c53f940e03"

PARTS_P="${PN}-parts-${PV}"
PARTS_COMMIT="e270ebfd8ee7dd40a6ef29ad0d3dba006e9eee61"

DESCRIPTION="Electronic Design Automation"
HOMEPAGE="https://fritzing.org/
	https://github.com/fritzing/fritzing-app/"
SRC_URI="https://github.com/fritzing/fritzing-app/archive/${APP_COMMIT}/${PV}-app-${APP_COMMIT}.tar.gz -> ${P}.tar.gz
	https://github.com/fritzing/fritzing-parts/archive/${PARTS_COMMIT}/${PV}-parts-${PARTS_COMMIT}.tar.gz -> ${PARTS_P}.tar.gz"

LICENSE="CC-BY-SA-3.0 GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="
	dev-libs/libgit2:=
	dev-libs/quazip:0=[qt5(+)]
	dev-qt/qtconcurrent:5
	dev-qt/qtcore:5
	dev-qt/qtgui:5
	dev-qt/qtnetwork:5
	dev-qt/qtprintsupport:5
	dev-qt/qtserialport:5
	dev-qt/qtsql:5[sqlite]
	dev-qt/qtsvg:5
	dev-qt/qtwidgets:5
	dev-qt/qtxml:5
"
DEPEND="${RDEPEND}
	dev-libs/boost
	sci-electronics/ngspice
"

S="${WORKDIR}/${PN}-app-${APP_COMMIT}"

DOCS=( README.md )

PATCHES=(
	"${FILESDIR}/${PN}-${PV}-disable-autoupdate.patch"
	"${FILESDIR}/${PN}-${PV}-unbundle-quazip.patch"
	"${FILESDIR}/${PN}-${PV}-remove-twitter4j.patch"
	"${FILESDIR}/${PN}-${PV}-move-parts-db-path.patch"
)

src_prepare() {
	xdg_src_prepare

	if has_version "<dev-libs/quazip-1.0"; then
		sed -e "/PKGCONFIG/s/quazip1-qt5/quazip/" -i phoenix.pro || die
	fi

	sed -e '/<url type="forum">/d' -i 'org.fritzing.Fritzing.appdata.xml'

	# Fritzing doesn't need zlib
	sed -i -e 's:LIBS += -lz::' -e 's:-lminizip::' phoenix.pro || die

	# Use system libgit
	sed -i -e 's:LIBGIT_STATIC.*:LIBGIT_STATIC = false:' phoenix.pro || die

	# Add correct git version
	sed -i -e "s:GIT_VERSION = \$\$system.*$:GIT_VERSION = ${APP_COMMIT}:" pri/gitversion.pri || die
}

src_configure() {
	eqmake5 'DEFINES=QUAZIP_INSTALLED PARTS_COMMIT=\\\"'"${PARTS_COMMIT}"'\\\"' phoenix.pro
}

src_build() {
	./Fritzing -platform minimal -f ./parts -db ./parts/parts.db
}

src_install() {
	PARTS_DIR="${WORKDIR}/fritzing-parts-${PARTS_COMMIT}"
	INSTALL_ROOT="${D}" default
	insinto /usr/share/fritzing/fritzing-parts
	doins -r ${PARTS_DIR}/*
}
