#!/bin/bash
qemu-system-x86_64 -kernel bzImage -initrd $(find . | grep ApertureOS | grep img) -nographic -append 'console=ttyS0'

