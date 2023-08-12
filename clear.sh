#!/bin/bash
rm $(find . | grep ApertureOS | grep img)
rm bzImage
rm -rf initrd #src
