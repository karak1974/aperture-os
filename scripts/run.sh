#!/bin/bash
qemu-system-x86_64 -kernel bzImage -initrd \
    $(find . | grep -Ei "MinSys[0-9]+\.[0-9]+\.img") \
    -nographic -append 'console=ttyS0'
