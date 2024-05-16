#!/bin/bash


# install packages
sudo dpkg --set-selections < ./packages.txt
sudo apt-get dselect-upgrade
