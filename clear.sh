#!/bin/bash
rm $(find . | grep -Ei "ApertureOS[0-9]+\.[0-9]+\.img")
rm bzImage
rm -rf initrd #src
