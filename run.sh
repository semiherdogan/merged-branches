#!/usr/bin/env bash

nim --run compile src/app \
    --threads:on \
    --opt:speed \
    --verbosity:0 \
    --backend:objc \
    -o:merged-branches \
    --styleCheck:hint \
    $@
