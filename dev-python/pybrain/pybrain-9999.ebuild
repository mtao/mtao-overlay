
EAPI=5
PYTHON_MULTIPLE_ABIS="1"
DISTUTILS_SRC_TEST="setup.py"

inherit distutils git-2

MY_P="PyBrain-${PV}"

DESCRIPTION="PyBrain is a modular Machine Learning Library for Python."
HOMEPAGE="http://pybrain.org"
EGIT_REPO_URI="https://github.com/pybrain/pybrain"

LICENSE=""
SLOT="0"
KEYWORDS="*"
IUSE="sci-libs/scipy"

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_P}"

PYTHON_CFLAGS=("2.* + -fno-strict-aliasing")

PYTHON_MODULES="pybrain"

pkg_setup() {
	python_pkg_setup
}

src_prepare() {
	distutils_src_prepare

}

src_install() {
	distutils_src_install
}
