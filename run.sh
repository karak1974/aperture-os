#!/bin/bash
qemu-system-x86_64 -kernel bzImage -initrd \
    $(find . | grep -Ei "ApertureOS[0-9]+\.[0-9]+\.img") \
    -nographic -append 'console=ttyS0'
