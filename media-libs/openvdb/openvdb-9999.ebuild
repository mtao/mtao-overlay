# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $
# copied from github.com/himikof/wis-core/gentoo-overlay...

#ilmbase
#boost
#openexr
#tbb
#
#USE:
#blosc
#jemalloc
#cppunit
#log4cplus
#glfw
#python-27 -> boost (with python USE) + (USE numpy + pydoc)
#doxygen 


EAPI=5

inherit git-2

DESCRIPTION="High-level C++ bindings for ZeroMQ"
HOMEPAGE="https://github.com/dreamworksanimation/openvdb_dev"
EGIT_REPO_URI="https://github.com/mtao/openvdb_dev"
EGIT_BRANCH="master"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc +blosc +jemalloc test logging glfw python pydoc"

RDEPEND="media-libs/ilmbase
dev-libs/boost
media-libs/openexr
dev-cpp/tbb
jemalloc? ( dev-libs/jemalloc )
blosc? ( dev-libs/c-blosc )
logging? ( dev-libs/log4cplus )
glfw? ( media-libs/glfw )
python? ( dev-lang/python:2.7 dev-libs/boost[python] dev-python/numpy dev-python/epydoc )
"
DEPEND="${RDEPEND}
doc? ( app-doc/doxygen )
test? ( dev-util/cppunit )"

LIB_VERSION="4"

set_flag() {
	$flagname = $1
	$varname = $2
	if use $flagname ; then
		sed -i \
			-e "s|^${varname}_INCL_DIR.*|${varname}_INCL_DIR := /usr/include|" \ 
		    -e "s|^${varname}_LIB_DIR.*|${varname}_LIB_DIR := /usr/lib|" \
			Makefile || die "sed failed"
	else
		sed -i \
			-e "s|^${varname}_INCL_DIR.*|${varname}_INCL_DIR :=|" \ 
			Makefile || die "sed failed"
	fi

}

src_configure() {
	sed -i \
		-e 's|^BOOST_INCL_DIR.*|BOOST_INCL_DIR := /usr/include|' \
		-e 's|^BOOST_LIB_DIR*|BOOST_LIB_DIR := /usr/lib|' \
		-e 's|^EXR_INCL_DIR.*|EXR_INCL_DIR := /usr/include|' \
		-e 's|^EXR_LIB_DIR*|EXR_LIB_DIR := /usr/lib|' \
		-e 's|^ILMBASE_INCL_DIR.*|ILMBASE_INCL_DIR := /usr/include|' \
		-e 's|^ILMBASE_LIB_DIR*|ILMBASE_LIB_DIR := /usr/lib|' \
		-e 's|^TBB_INCL_DIR.*|TBB_INCL_DIR := /usr/include|' \
		-e 's|^TBB_LIB_DIR*|TBB_LIB_DIR := /usr/lib|' \
		-e 's|^PREFIX = .*|PREFIX = /usr|' \
		Makefile || die "sed failed"

	if use jemalloc ; then
		sed -i \
			-e "s|^CONCURRENT_MALLOC_LIB :=.*|CONCURRENT_MALLOC_LIB := -jemalloc|" \ 
		    -e "s|^CONCURRENT_MaLLOC_LIB_DIR.*|CONCURRENT_MALLOC_LIB_DIR := /usr/lib|" \
			Makefile || die "sed failed"
	else
		sed -i \
			-e "s|^CONCURRENT_MALLOC_LIB :=.*|CONCURRENT_MALLOC_LIB :=|"\ 
			Makefile || die "sed failed"
	fi
	set_flag blosc BLOSC
	set_flag test CPPUNIT
	set_flag logging LOG4CPLUS
	set_flag glfw GLFW

	if use python ; then
		sed -i \
			-e 's|^PYTHON_INCL_DIR.*|PYTHON_INCL_DIR := /usr/include/python$(PYTHON_VERSION)|'\
			-e 's|^PYTHON_LIB_DIR.*|PYTHON_LIB_DIR := /usr/lib|'
			-e 's|^BOOST_PYTHON_LIB :=.*|BOOST_PYTHON_LIBR := -lboost_python-2.7-mt|'
	else
		sed -i \
			-e 's|^PYTHON_VERSION.*|PYTHON_VERSION :=|'
	fi

	if use pydoc; then
		sed -i \
			-e "s|^EPYDOC:=.*|EPYDOC:= epydoc|" \ 
			Makefile || die "sed failed"
	else
		sed -i \
			-e "s|^EPYDOC:=.*|EPYDOC:=|" \ 
			Makefile || die "sed failed"
	fi

	if use doc; then
		sed -i \
			-e "s|^DOXYGEN:=.*|DOXYGEN:= doxygen|" \ 
			Makefile || die "sed failed"
	else
		sed -i \
			-e "s|^DOXYGEN:=.*|DOXYGEN:=|" \ 
			Makefile || die "sed failed"
	fi
}

src_compile() {
	pushd openvdb
	emake 
	popd
}

src_install() {
	# work around primitive build system
	insinto /usr/include/openvdb
	doins openvdb/*.h
	doins openvdb/*/*.h
	dolib.so openvdb/openvdb.so
	#TODO: install doc and python doc somewhere
	#TODO install python stuff someewhere
	#TODO: glfw to put view somewhere
	#TODO: openexr to put render somewhere
}
