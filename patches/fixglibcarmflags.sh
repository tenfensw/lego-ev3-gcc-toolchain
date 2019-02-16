#!/bin/sh
if test "$1" != ""; then
	if test ! -e "$1"; then
		echo "ERROR!!! $1 does not exist."
		exit 2
	fi
	for File in $(find "$1" -type f -name "Makefile"); do
		cp -r -v "$File" "$File.old"
		cat "$File.old" | sed 's/-mcpu=arm/-mcpu=armv5/g' > "$File"
		rm -r -f -v "$File.old"
	done
	exit 0
else
	echo "ERROR!!! Please specify glibc sources as the only argument to this script."
	exit 1
fi
