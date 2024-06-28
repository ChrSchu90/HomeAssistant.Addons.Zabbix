#!/bin/bash
# shellcheck shell=dash

apt-get -y update && \ 
apt-get -y upgrade && \ 
apt-get -y autoremove && \
apt-get -y clean