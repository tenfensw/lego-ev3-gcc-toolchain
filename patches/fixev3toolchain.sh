#!/bin/sh
if test "$1" != ""; then
	if test ! -e "$1"; then
		echo "ERROR!!! $1 does not exist."
		exit 2
	fi
	cd "$1"
	if test -e "tcbin/"; then rm -r -f tcbin/; fi
	mkdir tcbin
	cd tcbin
	cat >>timkoisoft-ev3gccwrapper<<EOF
#!/bin/bash
# This is a wrapper to LEGO EV3 GCC toolchain.
CXXFLAGS="-static-libstdc++ -static-libgcc -Os -Wall"
CFLAGS="-static-libgcc -Os -Wall"

CURRENT_ARGS=""
for Argument in \$*; do
	if test "\$Argument" != "-O0" && test "\$Argument" != "-O1" && test "\$Argument" != "-O2" && test "\$Argument" != "-O3" && test "\$Argument" != "-static-libstdc++" && test "\$Argument" != "-static-libgcc" && test "\$Argument" != "-lstdc++" && test "\$Argument" != "-lgcc"; then
		if echo "\$Argument" | grep -q "\""; then
			CURRENT_ARGS="\$CURRENT_ARGS \"\$Argument\""
		else
			CURRENT_ARGS="\$CURRENT_ARGS \$Argument"
		fi
	fi
done

"$1/bin/\$(basename "\$0")" \$CURRENT_ARGS
exit \$?
EOF
	chmod 777 timkoisoft-ev3gccwrapper
	for File in arm-legoev3-linux-gnueabi-gcc arm-legoev3-linux-gnueabi-gcc-4.5.3 arm-legoev3-linux-gnueabi-g++ arm-legoev3-linux-gnueabi-c++; do
		ln -v -s "$(pwd)/timkoisoft-ev3gccwrapper" "$(pwd)/$File"
	done
	exit 0
else
	echo "ERROR!!! Please specify the toolchain path as the only argument to this script."
	exit 1
fi
