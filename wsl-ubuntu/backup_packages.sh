#!/usr/bin/env sh

dpkg --get-selections | grep -v deinstall > packages.txt
