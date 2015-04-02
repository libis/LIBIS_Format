#!/usr/bin/env bash
BASEDIR=$(dirname $0)
FIDO_PROG=$BASEDIR/fido.py

python "$FIDO_PROG" -bufsize 1000000 -container_bufsize 1000000 -q "$@"
