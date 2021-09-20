#!/usr/bin/env bash

nimble build -d:release &&
    mv merged-branches dist/merged-branches &&
    ./dist/merged-branches $@
