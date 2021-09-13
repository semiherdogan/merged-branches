#!/usr/bin/env bash

rm -rf dist
mkdir dist

APP_NAME="merged-branches"
ENTRT_FILE="src/app.nim"

function build_from_apple() {
    # Build from apple m1
    if [[ `uname -m` == 'arm64' ]]; then
        # Build for Apple M1
        nim c --threads:on -d:release --opt:size --app:console -d:ssl --out:dist/$APP_NAME-apple-m1 $ENTRT_FILE

        # Build for Apple Intel
        # Note: apple changed c compiler for m1 so we should use cpp compiler with intel version
        arch -x86_64 /bin/bash -c "nim c --threads:on -d:release --opt:size --app:console -d:ssl --backend=cpp --out:dist/$APP_NAME-apple-intel $ENTRT_FILE"
    else
        # Build from Apple Intel
        nim c --threads:on -d:release --opt:size --app:console -d:ssl --out:dist/$APP_NAME-apple-intel $ENTRT_FILE
    fi
}

function build_from_linux() {
    nim c --threads:on -d:release --opt:size --app:console -d:ssl --out:dist/$APP_NAME-linux $ENTRT_FILE
}

function build_from_windows() {
    nim c --threads:on -d:release --opt:size --app:console -d:ssl --out:dist/$APP_NAME-windows.exe $ENTRT_FILE
}

# Check platform and build
if [[ "$OSTYPE" == "darwin"* ]]; then
    build_from_apple
elif [[ "$OSTYPE" == "linux"* ]]; then
    build_from_linux
elif [[ "$OSTYPE" == "msys"* ]]; then
    build_from_windows
fi
