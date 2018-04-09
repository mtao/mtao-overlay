
EAPI=5
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

inherit distutils-r1 eutils multilib git-r3 flag-o-matic


DESCRIPTION="PyBrain is a modular Machine Learning Library for Python."
HOMEPAGE="http://pybrain.org"
EGIT_REPO_URI="https://github.com/pybrain/pybrain"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="sci-libs/scipy"

DEPEND="sci-libs/scipy[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}"

DISTUTILS_IN_SOURCE_BUILD=1


python_prepare_all() {

	export CC="$(tc-getCC) ${CFLAGS}"

	append-flags -fno-strict-aliasing

	# See progress in http://projects.scipy.org/scipy/numpy/ticket/573
	# with the subtle difference that we don't want to break Darwin where
	# -shared is not a valid linker argument
	if [[ ${CHOST} != *-darwin* ]]; then
		append-ldflags -shared
	fi



	distutils-r1_python_prepare_all
}

python_compile() {
	distutils-r1_python_compile
}

python_test() {
	distutils_install_for_testing
}

python_install() {
	distutils-r1_python_install
}

python_install_all() {

	distutils-r1_python_install_all

}
