#!/bin/sh

# ----------------------------------
# ENVIROMENT VARIABLES
# ----------------------------------
FRAMEWORK_SCHEMES=("BidMachineMediationModule")
LIB_SCHEMES=("AdMobMediationAdapter" , "BidMachineMediationAdapter" , "ApplovinMediationAdapter")
VERSION="0.0.1"

start=`date +%s`
# ----------------------------------
# CLEAR TEMPORARY AND RELEASE PATHS
# ----------------------------------
function prepare {
    rm -rf "./build"
    rm -rf "./release"
}

# ----------------------------------
# BUILD PLATFORM SPECIFIC FRAMEWORKS
# ----------------------------------
function xcframework {
    # iOS devices
    xcodebuild archive \
        -workspace "../BidMachineMediationModule.xcworkspace" \
        -scheme "BuildTarget" \
        -archivePath "./build/ios.xcarchive" \
        -sdk iphoneos \
        VALID_ARCHS="arm64 armv7" \
        GCC_GENERATE_DEBUGGING_SYMBOLS=NO \
        STRIP_INSTALLED_PRODUCT=YES \
        LINK_FRAMEWORKS_AUTOMATICALLY=NO \
                OTHER_CFLAGS="-fembed-bitcode -Qunused-arguments" \
                ONLY_ACTIVE_ARCH=NO \
                DEPLOYMENT_POSTPROCESSING=YES \
                MACH_O_TYPE=staticlib \
                IPHONEOS_DEPLOYMENT_TARGET=10.0 \
                DEBUG_INFORMATION_FORMAT="dwarf" \
        SKIP_INSTALL=NO | xcpretty

    # iOS simulator
    xcodebuild archive \
        -workspace "../BidMachineMediationModule.xcworkspace" \
        -scheme "BuildTarget" \
        -archivePath "./build/ios_sim.xcarchive" \
        -sdk iphonesimulator \
        VALID_ARCHS="x86_64 arm64" \
        GCC_GENERATE_DEBUGGING_SYMBOLS=NO \
        STRIP_INSTALLED_PRODUCT=YES \
        LINK_FRAMEWORKS_AUTOMATICALLY=NO \
                OTHER_CFLAGS="-fembed-bitcode -Qunused-arguments" \
                ONLY_ACTIVE_ARCH=NO \
                DEPLOYMENT_POSTPROCESSING=YES \
                MACH_O_TYPE=staticlib \
                IPHONEOS_DEPLOYMENT_TARGET=10.0 \
                DEBUG_INFORMATION_FORMAT="dwarf" \
        SKIP_INSTALL=NO | xcpretty
}

# -------------------
# PACKAGE XCFRAMEWORK
# -------------------

function packageFramework {
    scheme="$1"
    xcodebuild -create-xcframework \
        -framework "./build/ios.xcarchive/Products/Library/Frameworks/$scheme.framework" \
        -framework "./build/ios_sim.xcarchive/Products/Library/Frameworks/$scheme.framework" \
        -output "./release/$scheme.xcframework"
}

function packageLib {
    scheme="$1"
    xcodebuild -create-xcframework \
        -library "./build/ios.xcarchive/Products/usr/local/lib/lib$scheme.a" \
        -library "./build/ios_sim.xcarchive/Products/usr/local/lib/lib$scheme.a" \
        -output "./release/$scheme.xcframework"
}

# ----------------------------------
# COMPRESS
# ----------------------------------
function compress {
    echo "🗜 Compress packages"
    cp "./LICENSE" "./release/LICENSE"
    cp "./CHANGELOG.md" "./release/CHANGELOG.md"

    cd "./release"
    zip -r "BidMachineMediation.zip" * > /dev/null
    cd -
}

# ----------------------------------
# UPLOAD TO AWS S3
# ----------------------------------
function upload {
    echo "🌎 Upload"
    name="BidMachineMediation.zip"
    aws s3 cp "$(PWD)/release/$name" "s3://appodeal-ios/BidMachineMediation/$VERSION/$name" --acl public-read
}

prepare
xcframework
for scheme in ${FRAMEWORK_SCHEMES[@]}; do
    packageFramework "$scheme"
done

for scheme in ${LIB_SCHEMES[@]}; do
    packageLib "$scheme"
done

compress
upload

end=`date +%s`
runtime=$((end-start))
echo "🚀 Build finished at: $runtime seconds"
