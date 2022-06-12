#!/bin/bash

rm -rf build || true
mkdir build
pushd build

# Get the latest rime-cantonese files
git clone https://github.com/rime/rime-cantonese.git --depth 1 --branch master --single-branch

# Untar prebuilt Squirrel
tar xzf ../squirrel.tgz

# Overwrite prebuilt schema
cp -a ../scheme/* squirrel/build/Release/Squirrel.app/Contents/SharedSupport
cp -a rime-cantonese/*.yaml squirrel/build/Release/Squirrel.app/Contents/SharedSupport
cp -a rime-cantonese/opencc/* squirrel/build/Release/Squirrel.app/Contents/SharedSupport/opencc

# Resign Squirrel.app after changing files under SharedSupport
if [ ! -z "$APPLE_SIGNING_IDENT" ]; then
    KEYCHAIN_ARG=""
    if [ ! -z "$" ]; then
        KEYCHAIN_ARG=--keychain "$KEYCHAIN_PATH"
    fi
    echo "Resigning Squirrel.app after modification..."
    /usr/bin/codesign --force --verbose --deep $KEYCHAIN_ARG --sign "$APPLE_SIGNING_IDENT" squirrel/build/Release/Squirrel.app
fi

# Generate the installer
squirrel/package/make_package

mv squirrel/package/Squirrel.pkg Squirrel.pkg

popd
