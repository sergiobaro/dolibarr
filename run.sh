#!/usr/bin/env bash

swift build || exit 1
.build/debug/dolibarr $@
