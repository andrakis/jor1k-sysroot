#!/usr/bin/env bash
#
# Relink files in fs/ to or1k/basefs/
# Symlinks are not the same on all operating systems.
# This script will setup symlinks again using `ln`.

cd fs

# Clear old files and symlink again
rm fs.json
ln -s ../fs.json

# Remove symlink to uncompressed kernel
if [ -f "vmlinux.bin" ]; then
	rm vmlinux.bin
fi
cd ..

lp=

die () {
	echo $@
	exit 2
}

relink () {
	rm $1
	if [ "$2"x != "x" ]; then
		lp=$2
	fi
	full=$lp/$1
	if [ ! -e "$full" ]; then
		echo "Could not find $full from directory `pwd`"
		exit 1
	fi
	ln -s $lp/$1 && echo "Successfully rewrote symlink for $full"
}

relink_files () {
	pushd $1 > /dev/null || die "Failed to move to $1 from `pwd`"
	lp=$2
	for file in $3; do
		relink $file
	done
	popd > /dev/null
}

# Fix up kernel paths
relink_files fs ../or1k "vmlinux.bin.bz2 vmlinuxsmp.bin.bz2"

# Fix up local links
relink_files fs ../or1k/basefs "bin"
relink_files fs/etc ../../or1k/basefs/etc "fstab group host.conf inetd.conf init.d inittab network"
relink_files fs/etc ../../or1k/basefs/etc "nsswitch.conf passwd services"
relink_files fs/root ../../or1k/basefs/root "profile"
relink_files fs/usr/bin ../../../or1k/basefs/usr/bin "help showmenu"
relink_files fs/usr/share ../../../or1k/basefs/usr/share "udhcpc"
