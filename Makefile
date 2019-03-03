# Makefile for LEGO EV3 toolchain
# Copyright (C) 2018-2019 Tim K <timprogrammer@rambler.ru>. Licensed under ISC License (OpenBSD License).
# Permission to use, copy, modify, and distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
# 
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

prefix ?= /opt/timkoisoft/legoev3-toolchain

CC ?= cc
BUILD_PLATFORM = $(shell uname -m)-unknown-linux-gnu
ifeq ($(shell uname),Linux)
	BUILD_PLATFORM = $(shell uname -m)-unknown-linux-gnu
else ifeq ($(shell uname),FreeBSD)
	BUILD_PLATFORM = $(shell uname -m)-unknown-freebsd-gnu
else
	$(error Your platform is currently not supported)
endif
TOOLCHAIN_ID = arm-legoev3-linux-gnueabi

DOWNLOAD_COMMAND ?= wget -O-
CONFIGUREFLAGS = --build=$(BUILD_PLATFORM) --target=$(TOOLCHAIN_ID) --disable-werror --enable-nls --disable-multilib --with-pkgversion="Tim's LEGO Mindstorms EV3 GCC toolchain" --prefix=$(prefix)

GLIBC_MIRROR = http://ftpmirror.gnu.org/gnu/glibc/glibc-2.8.tar.gz
BINUTILS_MIRROR = http://ftpmirror.gnu.org/gnu/binutils/binutils-2.22.tar.gz
GCC_MIRROR = http://ftpmirror.gnu.org/gnu/gcc/gcc-4.5.3/gcc-4.5.3.tar.gz
KERNEL_MIRROR = http://mirror.yandex.ru/pub/linux/kernel/v2.6/longterm/linux-2.6.32.47.tar.gz
LCPORTS_MIRROR = http://ftpmirror.gnu.org/gnu/glibc/glibc-ports-2.8.tar.gz
ifdef MODERN
	GCC_MIRROR = http://ftpmirror.gnu.org/gnu/gcc/gcc-7.4.0/gcc-7.4.0.tar.gz
	BINUTILS_MIRROR = http://ftpmirror.gnu.org/gnu/binutils/binutils-2.30.tar.gz
	GMP_MIRROR ?= http://ftpmirror.gnu.org/gnu/gmp/gmp-5.1.3.tar.gz
	MPC_MIRROR ?= http://ftpmirror.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
	MPFR_MIRROR ?= http://ftpmirror.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.gz
else
	MPFR_MIRROR ?= http://ftpmirror.gnu.org/gnu/mpfr/mpfr-2.4.2.tar.gz
	MPC_MIRROR ?= http://ftpmirror.gnu.org/gnu/mpc/mpc-1.0.1.tar.gz
	GMP_MIRROR ?= http://ftpmirror.gnu.org/gnu/gmp/gmp-5.0.2.tar.gz
endif

all: check-systemrequirements stage0-preparedir stage1-kernelheaders stage2-binutils stage3-gcc stage4-libc stage5-gcc stage6-libc stage7-gcc stage8-ev3duder stage9-ev3clib stage10-finalpreparations

stage0-preparedir:
	@if test -e "$(PWD)/.stage0"; then echo "stage0 already finished"; else if test -e "$(prefix)"; then touch "$(PWD)/.stage0"; else $(MAKE) INTUSER=$(shell whoami) internal-mkdir-stage0 && touch "$(PWD)/.stage0"; fi; fi

stage1-kernelheaders:
	@if test -e "$(PWD)/.stage1"; then echo "stage1 already finished"; else $(MAKE) internal-kernel-stage1 && touch "$(PWD)/.stage1"; fi

stage2-binutils:
	@if test -e "$(PWD)/.stage2"; then echo "stage2 already finished"; else $(MAKE) internal-binutils-stage2 && touch "$(PWD)/.stage2"; fi

stage3-gcc:
	@if test -e "$(PWD)/.stage3"; then echo "stage3 already finished"; else $(MAKE) internal-gcc-stage3 && touch "$(PWD)/.stage3"; fi

stage4-libc:
	@if test -e "$(PWD)/.stage4"; then echo "stage4 already finished"; else $(MAKE) internal-glibc-stage4 && touch "$(PWD)/.stage4"; fi

stage5-gcc:
	@if test -e "$(PWD)/.stage5"; then echo "stage5 already finished"; else $(MAKE) internal-gcc-stage5 && touch "$(PWD)/.stage5"; fi

stage6-libc:
	@if test -e "$(PWD)/.stage6"; then echo "stage6 already finished"; else $(MAKE) internal-glibc-stage6 && touch "$(PWD)/.stage6"; fi

stage7-gcc:
	@if test -e "$(PWD)/.stage7"; then echo "stage7 already finished"; else $(MAKE) internal-gcc-stage7 && touch "$(PWD)/.stage7"; fi

stage8-ev3duder:
	@if test -e "$(PWD)/.stage8"; then echo "stage8 already finished"; else $(MAKE) internal-ev3duder-stage8 && touch "$(PWD)/.stage8"; fi	

stage9-ev3clib:
	@if test -e "$(PWD)/.stage9"; then echo "stage9 already finished"; else $(MAKE) internal-ev3api-stage9 && touch "$(PWD)/.stage9"; fi	

stage10-finalpreparations:
	@if test -e "$(PWD)/.stage10"; then echo "stage10 already finished"; else $(MAKE) internal-final-stage10 && touch "$(PWD)/.stage10"; fi	
	

check-systemrequirements:
	@if test -e "$(PWD)/.syschecked"; then echo "skipping system requirements check" && exit 0; else $(MAKE) check-systemrequirements-part2; fi

check-systemrequirements-part2:
	@echo "detected compiler is $(CC)"
	@if command -v pkg-config > /dev/null 2>&1; then echo "pkg-config found"; else echo "pkg-config not found" && exit 1; fi
	@if pkg-config --cflags libudev > /dev/null; then echo "libudev is installed"; else exit 2; fi
	@if command -v git > /dev/null 2>&1; then echo "git is installed"; else echo "git is not installed" && exit 3; fi
	@if command -v gperf > /dev/null 2>&1; then echo "gperf is installed"; else echo "gperf is not installed" && exit 4; fi
	@echo "system check completed"
	@touch "$(PWD)/.syschecked"

internal-mkdir-stage0:
	if mkdir -p "$(prefix)"; then echo mkdir works && chown -v -R $(INTUSER):users "$(prefix)"; else echo root password is required to create the output directory && su -c "mkdir -p $(prefix) && chown -v -R $(INTUSER):users \"$(prefix)\""; fi

internal-kernel-stage1:
	if test -e "stage1-kernelheaders-build/"; then rm -r -f stage1-kernelheaders-build/; fi
	mkdir stage1-kernelheaders-build/
	$(DOWNLOAD_COMMAND) $(KERNEL_MIRROR) | gunzip - | tar --strip-components=1 -C $(PWD)/stage1-kernelheaders-build/ -xf -
	cd $(PWD)/stage1-kernelheaders-build && make mrproper && make ARCH=arm INSTALL_HDR_PATH=$(prefix)/$(TOOLCHAIN_ID) headers_install

internal-binutils-stage2:
	if test -e "stage2-binutils-build/"; then rm -r -f stage2-binutils-build/; fi
	mkdir stage2-binutils-build/
	$(DOWNLOAD_COMMAND) $(BINUTILS_MIRROR) | gunzip - | tar --strip-components=1 -C $(PWD)/stage2-binutils-build/ -xf -
	cd $(PWD)/stage2-binutils-build/ && mkdir outofsource && cd outofsource && CC=$(CC) ../configure $(CONFIGUREFLAGS) --with-arch=armv5 --with-float=soft && make && make install

internal-gcc-stage3:
	if test -e "stage3-gcc-buildp1/"; then rm -r -f stage3-gcc-buildp1/ && sh -c "if unlink stage5-gcc-buildp2 && unlink stage7-gcc-buildp3; then echo ok; else exit 0; fi"; fi
	mkdir stage3-gcc-buildp1/
	$(DOWNLOAD_COMMAND) $(GCC_MIRROR) | gunzip - | tar --strip-components=1 -C $(PWD)/stage3-gcc-buildp1/ -xf -
	ln -s stage3-gcc-buildp1 stage5-gcc-buildp2
	ln -s stage3-gcc-buildp1 stage7-gcc-buildp3
	cp $(PWD)/stage3-gcc-buildp1/gcc/cp/cfns.gperf $(PWD)/stage3-gcc-buildp1/gcc/cp/cfns.gperf.old
	cat $(PWD)/stage3-gcc-buildp1/gcc/cp/cfns.gperf.old | sed 's+__inline+//__inline+g' > $(PWD)/stage3-gcc-buildp1/gcc/cp/cfns.gperf
	rm -r -f $(PWD)/stage3-gcc-buildp1/gcc/cp/cfns.gperf.old
	chmod 777 $(PWD)/patches/fixgccdoc.sh
	sh $(PWD)/patches/fixgccdoc.sh "$(PWD)/stage3-gcc-buildp1/gcc/doc"
	if test -e "$(PWD)/stage3-gcc-buildp1/contrib/download_prerequisites"; then sh -c "cd $(PWD)/stage3-gcc-buildp1 && ./contrib/download_prerequisites"; else $(MAKE) gccdir="$(PWD)/stage3-gcc-buildp1" MPFR_MIRROR="$(MPFR_MIRROR)" MPC_MIRROR="$(MPC_MIRROR)" GMP_MIRROR="$(GMP_MIRROR)" internal-gcc-downloadcomponents; fi
	cd $(PWD)/stage3-gcc-buildp1 && mkdir outofsource && cd outofsource && CC=$(CC) ../configure $(CONFIGUREFLAGS) --with-arch=armv5 --with-float=soft --enable-languages=c,c++ --disable-libquadmath --disable-libquadmath-support --disable-libssp --disable-libada --with-pkgversion="Tim's LEGO Mindstorms EV3 GCC builds" && make all-gcc && make install-gcc

internal-gcc-downloadcomponents:
	sh -c "cd \"$(gccdir)\" && mkdir mpfr && $(DOWNLOAD_COMMAND) \"$(MPFR_MIRROR)\" | gunzip - | tar --strip-components=1 -C ./mpfr -xf -"
	sh -c "cd \"$(gccdir)\" && mkdir mpc && $(DOWNLOAD_COMMAND) \"$(MPC_MIRROR)\" | gunzip - | tar --strip-components=1 -C ./mpc -xf -"
	sh -c "cd \"$(gccdir)\" && mkdir gmp && $(DOWNLOAD_COMMAND) \"$(GMP_MIRROR)\" | gunzip - | tar --strip-components=1 -C ./gmp -xf -"


internal-glibc-stage4:
	if test -e "stage4-glibc-buildp1/"; then rm -r -f stage4-glibc-buildp1/ stage6-glibc-buildp2; fi
	mkdir stage4-glibc-buildp1/
	ln -s $(PWD)/stage4-glibc-buildp1 stage6-glibc-buildp2
	$(DOWNLOAD_COMMAND) $(GLIBC_MIRROR) | gunzip - | tar --strip-components=1 -C $(PWD)/stage4-glibc-buildp1/ -xf -
	cd $(PWD)/stage4-glibc-buildp1 && $(DOWNLOAD_COMMAND) $(LCPORTS_MIRROR) > lcports.tgz && mkdir ports && tar --strip-components=1 -C ports/ -xvzf lcports.tgz && rm -r -f -v lcports.tgz
	cd $(PWD)/stage4-glibc-buildp1 && cp $(PWD)/patches/glibc-2.8-configure ./configure.new && rm -r -f ./configure && mv -v ./configure.new ./configure && rm -r -f ./nptl/sysdeps/pthread/configure && cp $(PWD)/patches/nptl-glibc-configure ./nptl/sysdeps/pthread/configure && rm -r -f ./elf/Makefile && cp "$(PWD)/patches/glibc-2.8-elfmakefile" ./elf/Makefile && mkdir outofsource && cd outofsource && PATH="$(prefix)/bin:$(PATH)" ../configure --prefix="$(prefix)/$(TOOLCHAIN_ID)" --build=$(BUILD_PLATFORM) --host=$(TOOLCHAIN_ID) --target=$(TOOLCHAIN_ID) --with-fp --with-elf --with-float=soft --with-headers="$(prefix)/$(TOOLCHAIN_ID)/include" --with-binutils="$(prefix)/$(TOOLCHAIN_ID)/bin" --enable-kernel=2.6.7 --enable-add-ons=nptl,ports --disable-profile --enable-shared --with-cpu=armv5 --with-pkgversion="Tim's LEGO Mindstorms EV3 GCC builds" libc_ev_forced_unwind=yes && sh "$(PWD)/patches/fixglibcarmflags.sh" "$(PWD)/stage4-glibc-buildp1" && mv -v ../manual/Makefile ../manual/Makefile.old && sh -c "cat ../manual/Makefile.old | sed 's/stubs: /before-stubs: /g' | sed 's/stamp%/stamp/g' > ../manual/Makefile" && sh -c "echo \"\" >> ../manual/Makefile && echo \"stubs:\" >> ../manual/Makefile && echo -e \"\\\techo this fails to work\" >> ../manual/Makefile" && PATH="$(prefix)/bin:$(PATH)" make install-bootstrap-headers=yes install-headers && PATH="$(prefix)/bin:$(PATH)" make csu/subdir_lib && install csu/crt1.o csu/crti.o csu/crtn.o "$(prefix)/$(TOOLCHAIN_ID)/lib" && "$(prefix)/bin/$(TOOLCHAIN_ID)-gcc" -nostartfiles -nostdlib -shared -x c /dev/null -o "$(prefix)/$(TOOLCHAIN_ID)/lib/libc.so" && if test ! -e "$(prefix)/$(TOOLCHAIN_ID)/include/gnu"; then mkdir -p "$(prefix)/$(TOOLCHAIN_ID)/include/gnu"; fi && touch "$(prefix)/$(TOOLCHAIN_ID)/include/gnu/stubs.h"

internal-gcc-stage5:
	cd $(PWD)/stage5-gcc-buildp2/outofsource && make all-target-libgcc && make install-target-libgcc

internal-glibc-stage6:
	cd $(PWD)/stage6-glibc-buildp2/outofsource && touch ./manual/stubs && sh -c "cat \"$(PWD)/patches/glibc-2.8-manual-snippet\" >> ../manual/Makefile" && PATH="$(prefix)/bin:$(PATH)" sh -c "make && make install"

internal-gcc-stage7:
	cd $(PWD)/stage7-gcc-buildp3/outofsource && make && make install

internal-ev3duder-stage8:
	if test -e "stage8-ev3duder-build/"; then rm -r -f stage8-ev3duder-build/; fi
	git clone --recursive https://github.com/c4ev3/ev3duder
	mv -v ev3duder/ stage8-ev3duder-build/
	cd $(PWD)/stage8-ev3duder-build/ && make && mv -v Makefile Makefile.old && sh -c "cat Makefile.old | sed \"s+/usr+$(prefix)+g\" | sed 's/INSTALL =/INSTALL ?=/g' > ./Makefile" && if test ! -e "$(prefix)/libexec/ev3duder-udevinstall"; then mkdir -p "$(prefix)/libexec/ev3duder-udevinstall"; fi && make install INSTALL="cp ev3-udev.rules $(prefix)/libexec/ev3duder-udevinstall/ev3-udev.rules && cp udev.sh $(prefix)/libexec/ev3duder-udevinstall/udev.sh.real" && cp $(PWD)/patches/ev3duder-udevinstall-script $(prefix)/libexec/ev3duder-udevinstall/udev.sh
	
internal-ev3api-stage9:
	if test -e "stage9-ev3api-build/"; then rm -r -f stage9-ev3api-build/; fi
	mv -v $(PWD)/stage8-ev3duder-build/EV3-API/API ./stage9-ev3api-build
	cd $(PWD)/stage9-ev3api-build && mv -v Makefile Makefile.old && sh -c "cat Makefile.old | sed 's/override/#override/g' | sed 's/PREFIX =/PREFIX ?=/g' > Makefile" && make PREFIX="$(prefix)/bin/$(TOOLCHAIN_ID)-" && cp libev3api.a "$(prefix)/lib/libev3api.a" && chmod 777 "$(prefix)/lib/libev3api.a" 

internal-final-stage10:
	sh $(PWD)/patches/fixev3toolchain.sh "$(prefix)"

distclean: clean

clean:
	@if test "$(NO_SAFE_CLEAN)" != ""; then make prefix="$(prefix)" clean-everything; else make safe-clean; fi

safe-clean:
	rm -r -f stage*
	rm -r -f ./.syschecked ./.stage*

clean-everything:
	make safe-clean
	rm -r -f "$(prefix)"
