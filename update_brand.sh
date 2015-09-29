#!/usr/bin/env bash
curdir=$(pwd)
cd $(dirname $0)
utildir=$(pwd)

cp -f ${utildir}/brand/* ${curdir}