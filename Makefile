CXX = g++
CXXFLAGS = -O2 -g3 -std=c++11 -fPIC

RM = rm
LN = ln
AR = ar
RANLIB = ranlib

LIBRARY_FILES = \
	AsmMacros.hpp \
	AuxSTL.hpp\
	BigInt.hpp \
	EC_BN128_GroupCurve.hpp \
	EC_BN128_InitFields.hpp \
	EC_BN128_InitGroups.hpp \
	EC_BN128_Modulus.hpp \
	EC_BN128_Pairing.hpp \
	EC_Edwards_GroupCurve.hpp \
	EC_Edwards_InitFields.hpp \
	EC_Edwards_InitGroups.hpp \
	EC_Edwards_Modulus.hpp \
	EC_Edwards_Pairing.hpp \
	EC.hpp \
	EC_Pairing.hpp \
	Field.hpp \
	FpModel.hpp \
	FpModel.tcc \
	FpX.hpp \
	Group.hpp \
	HugeSystem.hpp \
	IndexSpace.hpp \
	LagrangeFFT.hpp \
	LagrangeFFTX.hpp \
	MultiExp.hpp \
	Pairing.hpp \
	PPZK_keypair.hpp \
	PPZK_keystruct.hpp \
	PPZK_proof.hpp \
	PPZK_query.hpp \
	PPZK_randomness.hpp \
	PPZK_verify.hpp \
	PPZK_witness.hpp \
	ProgressCallback.hpp \
	QAP_query.hpp \
	QAP_system.hpp \
	QAP_witness.hpp \
	Rank1DSL.hpp \
	Util.hpp \
	WindowExp.hpp

default :
	@echo Build options:
	@echo make autotest_bn128 LIBSNARK_PREFIX=\<path\>
	@echo make autotest_edwards LIBSNARK_PREFIX=\<path\>
	@echo make install PREFIX=\<path\>
	@echo make doc
	@echo make clean

README.html : README.md
	markdown_py -f README.html README.md -x toc -x extra --noisy

doc : README.html

# need symbolic link for header file paths
snarklib :
	$(LN) -s . snarklib

ifeq ($(PREFIX),)
install :
	$(error Please provide PREFIX, e.g. make install PREFIX=/usr/local)
else
# installing just copies over the template library header files
install :
	mkdir -p $(PREFIX)/include/snarklib
	cp $(LIBRARY_FILES) $(PREFIX)/include/snarklib
endif

CLEAN_FILES = \
	autotest_bn128 \
	autotest_bn128_oldlibsnark \
	autotest_edwards \
	autotest_edwards_oldlibsnark \
	README.html

clean :
	$(RM) -f *.o autotest_tmpfile* $(CLEAN_FILES) snarklib


################################################################################
# CURVE_ALT_BN128
#

ifeq ($(LIBSNARK_PREFIX),)
autotest_bn128 :
	$(error Please provide LIBSNARK_PREFIX, e.g. make autotest_bn128 LIBSNARK_PREFIX=/usr/local)

autotest_bn128_oldlibsnark :
	$(error Please provide LIBSNARK_PREFIX, e.g. make autotest_bn128_oldlibsnark LIBSNARK_PREFIX=/usr/local)
else
CXXFLAGS_CURVE_ALT_BN128 = \
	-I. -I$(LIBSNARK_PREFIX)/include/libsnark \
	-DCURVE_ALT_BN128 -DUSE_ASM -DUSE_ADD_SPECIAL -DUSE_ASSERT

LDFLAGS_CURVE_ALT_BN128 = \
	-L$(LIBSNARK_PREFIX)/lib \
	-Wl,-rpath $(LIBSNARK_PREFIX)/lib \
	-lgmpxx -lgmp -lsnark

autotest_bn128 : autotest.cpp $(LIBRARY_FILES) snarklib
	$(CXX) -c $(CXXFLAGS) $(CXXFLAGS_CURVE_ALT_BN128) -DUSE_MIXED_ADDITION $< -o autotest_bn128.o
	$(CXX) -o $@ autotest_bn128.o $(LDFLAGS_CURVE_ALT_BN128) -lprocps

# link does not need procps even when libsnark is built with it
autotest_bn128_oldlibsnark : autotest.cpp $(LIBRARY_FILES) snarklib
	$(CXX) -c $(CXXFLAGS) $(CXXFLAGS_CURVE_ALT_BN128) -DUSE_OLD_LIBSNARK $< -o autotest_bn128.o
	$(CXX) -o $@ autotest_bn128.o $(LDFLAGS_CURVE_ALT_BN128)
endif


################################################################################
# CURVE_EDWARDS
#

ifeq ($(LIBSNARK_PREFIX),)
autotest_edwards :
	$(error Please provide LIBSNARK_PREFIX, e.g. make autotest_edwards LIBSNARK_PREFIX=/usr/local)

autotest_edwards_oldlibsnark :
	$(error Please provide LIBSNARK_PREFIX, e.g. make autotest_edwards_oldlibsnark LIBSNARK_PREFIX=/usr/local)
else
CXXFLAGS_CURVE_EDWARDS = \
	-I. -I$(LIBSNARK_PREFIX)/include/libsnark \
	-DCURVE_EDWARDS -DUSE_ASM -DUSE_ADD_SPECIAL -DUSE_ASSERT

LDFLAGS_CURVE_EDWARDS = \
	-L$(LIBSNARK_PREFIX)/lib \
	-Wl,-rpath $(LIBSNARK_PREFIX)/lib \
	-lgmpxx -lgmp -lsnark

autotest_edwards : autotest.cpp $(LIBRARY_FILES) snarklib
	$(CXX) -c $(CXXFLAGS) $(CXXFLAGS_CURVE_EDWARDS) -DUSE_MIXED_ADDITION $< -o autotest_edwards.o
	$(CXX) -o $@ autotest_edwards.o $(LDFLAGS_CURVE_EDWARDS) -lprocps

# link does not need procps even when libsnark is built with it
autotest_edwards_oldlibsnark : autotest.cpp $(LIBRARY_FILES) snarklib
	$(CXX) -c $(CXXFLAGS) $(CXXFLAGS_CURVE_EDWARDS) -DUSE_OLD_LIBSNARK $< -o autotest_edwards.o
	$(CXX) -o $@ autotest_edwards.o $(LDFLAGS_CURVE_EDWARDS)
endif
