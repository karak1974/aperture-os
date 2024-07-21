#!/bin/bash
rm -f $(find . | grep -Ei "MinSys[0-9]+\.[0-9]+\.img")
rm -f bzImage
rm -rf initrd
