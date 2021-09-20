#!/usr/bin/env bash

nim --run compile src/app \
    --threads:on \
    --opt:speed \
    --verbosity:0 \
    --backend:objc \
    --styleCheck:hint \
    $@

rm src/app
