#!/bin/bash

# Create a ISO9660 file system
# -o Filename to be created
# -b The path and file name of the boot image
# -c boot-catalog
# -boot-load-size Specified the number of "virtual" sectors to load
# -boot-info-table Specifies the use of a layout table is available
# -R Further required protocol
# -J Generate Joliet director records
# -v Verbose
# -T The directory to use for generating the ISO file


mkisofs -o CentOS6.6-x86_64-boot.iso \
-b islinux.bin -c boot.cat -no-emul-boot \
-boot-load-size 4 -boot-info-table -R -J -v \
-T /var/install/sysadmin/isolinux
