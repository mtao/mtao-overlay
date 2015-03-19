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

inherit git-2 python
PYTHON_DEPEND="2"

DESCRIPTION="High-level C++ bindings for ZeroMQ"
HOMEPAGE="https://github.com/dreamworksanimation/openvdb_dev"
EGIT_REPO_URI="https://github.com/mtao/openvdb_dev"
EGIT_BRANCH="master"

LICENSE="MPL-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="python clang -doc -blosc +jemalloc -test -logging viewer -pydoc"

RDEPEND="media-libs/ilmbase
dev-libs/boost
media-libs/openexr
dev-cpp/tbb
clang? ( sys-devel/clang )
jemalloc? ( dev-libs/jemalloc )
blosc? ( dev-libs/c-blosc )
logging? ( dev-libs/log4cplus )
viewer? ( media-libs/glfw )
python? ( dev-lang/python:2.7 dev-libs/boost[python] dev-python/numpy dev-python/epydoc )
"
DEPEND="${RDEPEND}
doc? ( app-doc/doxygen )
test? ( dev-util/cppunit )"

LIB_VERSION="4"

set_flag() {
	flagname=$1
	varname=$2
	if  use $flagname ; then
		inclCmd="s|^${varname}_INCL_DIR.*|${varname}_INCL_DIR:=/usr/include|"
		libCmd="s|^${varname}_LIB_DIR.*|${varname}_LIB_DIR:=|"
		sed -i -e "$inclCmd" -e "$libCmd" Makefile || die "sed failed on $flagname"
	else
		inclCmd="s|^${varname}_INCL_DIR.*|${varname}_INCL_DIR:=|"
		sed -i -e "$inclCmd" Makefile || die "sed failed on no $flagname"
	fi

}

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi


}

src_configure() {
	pushd openvdb
	sed -i \
		-e 's|^BOOST_INCL_DIR.*|BOOST_INCL_DIR:=/usr/include|' \
		-e 's|^BOOST_LIB_DIR*|BOOST_LIB_DIR:=|' \
		-e 's|^EXR_INCL_DIR.*|EXR_INCL_DIR:=/usr/include|' \
		-e 's|^EXR_LIB_DIR*|EXR_LIB_DIR:=|' \
		-e 's|^ILMBASE_INCL_DIR.*|ILMBASE_INCL_DIR:=/usr/include|' \
		-e 's|^ILMBASE_LIB_DIR*|ILMBASE_LIB_DIR:=|' \
		-e 's|^TBB_INCL_DIR.*|TBB_INCL_DIR:=/usr/include|' \
		-e 's|^TBB_LIB_DIR*|TBB_LIB_DIR:=|' \
		-e 's|^PREFIX = .*|PREFIX = /usr|' \
		Makefile || die "sed failed"

	sed -i -e 's|-L$(ILMBASE_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-L$(BLOSC_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-L$(TBB_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-L$(BOOST_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-L$(LOG4PLUS_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-L$CONCURRENT_MALLOC_LIB_DIR)||' Makefile || die "half supression failed"

	sed -i -e 's|-Wl,-rpath,$(ILMBASE_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-Wl,-rpath,$(TBB_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-Wl,-rpath,$(BOOST_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-Wl,-rpath,$(BLOSC_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-Wl,-rpath,$(LOG4CPLUS_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-Wl,-rpath,$(CONCURRENT_MALLOC_LIB_DIR)||' Makefile || die "half supression failed"

	sed -i -e 's|-L$(EXR_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-Wl,-rpath,$(EXR_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-L$(GLFW_LIB_DIR)||' Makefile || die "half supression failed"
	sed -i -e 's|-Wl,-rpath,$(GLFW_LIB_DIR)||' Makefile || die "half supression failed"

	if use jemalloc ; then
		sed -i \
			-e "s|^CONCURRENT_MALLOC_LIB_DIR.*|CONCURRENT_MALLOC_LIB_DIR:=|" Makefile || die "sed failed"
	else
		sed -i \
			-e "s|^CONCURRENT_MALLOC_LIB :=.*|CONCURRENT_MALLOC_LIB :=|"\ 
			Makefile || die "sed failed"
	fi
	set_flag blosc BLOSC
	set_flag test CPPUNIT
	set_flag logging LOG4CPLUS
	set_flag viewer GLFW

	if use python ; then
		inclCmd='s|^PYTHON_INCL_DIR.*|PYTHON_INCL_DIR:=/usr/include/python$(PYTHON_VERSION)|'
		libCmd='s|^PYTHON_LIB_DIR.*|PYTHON_LIB_DIR:=/usr/lib64|'
		pyBCmd='s|^BOOST_PYTHON_LIB :=.*|BOOST_PYTHON_LIB :=-lboost_python-2.7-mt|'
		#sedcmd="sed -i -e \"$inclCmd\" -e \"$libCmd\" -e \"$pyBCmd\" Makefile || die \"sed died\""
		sed -i -e "$inclCmd" -e "$libCmd" -e "$pyBCmd" Makefile || die "sed failed on python"
	else
		sed -i -e 's|^PYTHON_VERSION.*|PYTHON_VERSION :=|' Makefile || die "sed failed on no python"
	fi

	sed -i -e 's|^TBB_LIB_DIR.*|TBB_LIB_DIR:=|' Makefile || die "sed tbb failed"
	sed -i -e 's|^EXR_LIB_DIR.*|EXR_LIB_DIR:=|' Makefile || die "sed exr failed"
	sed -i -e 's|^BOOST_LIB_DIR.*|BOOST_LIB_DIR:=|' Makefile || die "sed boost failed"
	if use pydoc; then
		sed -i \
			-e "s|^EPYDOC:=.*|EPYDOC:= epydoc|" \ 
			Makefile || die "sed failed on pydoc"
	else
		sed -i -e "s|^EPYDOC:=.*|EPYDOC:=|" Makefile || die "sed failed on no pydoc"
	fi

	if use doc; then
		sed -i -e "s|^DOXYGEN:=.*|DOXYGEN:= doxygen|" Makefile || die "sed failed on doc"
	else
		sed -i -e "s|^DOXYGEN:=.*|DOXYGEN:=|" Makefile || die "sed failed no doc"
	fi
	popd
}

src_compile() {
	pushd openvdb
	CCOPTS=
	if use clang; then
		CCOPTS=CXX=clang++ CC=clang
	fi
	emake $CCOPTS lib
	emake $CCOPTS vdb_print
	if use viewer; then
		emake $CCOPTS vdb_viewer
	fi
	if use python; then
		emake $CCOPTS python
	fi
	popd
}

src_install() {
	# work around primitive build system
	mylibdir="${ED}$(python_get_libdir)/"
	pwd
	echo ${mylibdir}
	insinto /usr/include/openvdb
	doins openvdb/*.h
	for d in io math metadata tools tree util;
	do 
		insinto /usr/include/openvdb/$d
		doins openvdb/$d/*.h
	done
	dolib.so openvdb/libopenvdb.so*

	dobin openvdb/vdb_print

	if use viewer; then
		dobin openvdb/vdb_view
	fi
	if use python; then
		insinto "$(python_get_includedir)"
		doins openvdb/python/*.h
		mkdir -p "${mylibdir}"
		cp "openvdb/pyopenvdb.so" "${mylibdir}"
		#dolib.so openvdb/pyopenvdb.so*
	fi
	#TODO: install doc and python doc somewhere
	#TODO install python stuff someewhere
	#TODO: openexr to put render somewhere
}
