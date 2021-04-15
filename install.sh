#!/usr/bin/env bash

swift build -c release || exit 1
cp .build/release/dolibarr /usr/local/bin/dolibarr
