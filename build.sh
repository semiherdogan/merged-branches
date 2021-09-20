#!/usr/bin/env bash

APP_NAME="merged-branches"

rm $APP_NAME
rm -rf dist
mkdir dist

function build_from_apple() {
    # Build from apple m1
    if [[ `uname -m` == 'arm64' ]]; then
        # Build for Apple M1
        nimble build && mv $APP_NAME dist/$APP_NAME-apple-m1

        # Build for Apple Intel
        # Note: apple changed c compiler for m1 so we should use cpp compiler with intel version
        arch -x86_64 /bin/bash -c "nimble build --backend:cpp && mv $APP_NAME dist/$APP_NAME-apple-intel"
    else
        # Build from Apple Intel
        nimble build && mv $APP_NAME dist/$APP_NAME-apple-intel
    fi
}

function build_from_linux() {
    nimble build && mv $APP_NAME dist/$APP_NAME-linux
}

function build_from_windows() {
    nimble build && mv $APP_NAME dist/$APP_NAME-windows.exe
}

# Check platform and build
if [[ "$OSTYPE" == "darwin"* ]]; then
    build_from_apple
elif [[ "$OSTYPE" == "linux"* ]]; then
    build_from_linux
elif [[ "$OSTYPE" == "msys"* ]]; then
    build_from_windows
fi
