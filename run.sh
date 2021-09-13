#!/usr/bin/env bash

OUTPUT_FILE=dist/app

rm -f $OUTPUT_FILE

nim c --threads:on --out:$OUTPUT_FILE src/app.nim &&
    clear &&
    ./$OUTPUT_FILE $@
