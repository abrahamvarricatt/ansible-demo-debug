#!/bin/bash

./configure \
    --enable-shared \
    --with-system-ffi \
    --with-system-expat \
    --prefix=/opt/python3-altinstall \
    LDFLAGS="-L/opt/python3-altinstall/extlib/lib -Wl,--rpath=/opt/python3-altinstall/lib -Wl,--rpath=/opt/python3-altinstall/extlib/lib" \
    CPPFLAGS="-I/opt/python3-altinstall/extlib/include"

make
make altinstall


