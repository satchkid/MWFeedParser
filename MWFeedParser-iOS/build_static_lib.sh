#!/bin/sh

# Function for handling errors
die() {
    echo ""
    echo "$*" >&2
    exit 1
}

# The Xcode bin path
if [ -d "/Developer/usr/bin" ]; then
   # < XCode 4.3.1
  XCODEBUILD_PATH=/Developer/usr/bin
else
  # >= XCode 4.3.1, or from App store
  XCODEBUILD_PATH=/Applications/XCode.app/Contents/Developer/usr/bin
fi
XCODEBUILD=$XCODEBUILD_PATH/xcodebuild
test -x "$XCODEBUILD" || die "Could not find xcodebuild in $XCODEBUILD_PATH"


# Get the path and set the relative directories used
# for compilation
cd $(dirname $0)
SCRIPTPATH=`pwd`
cd ..

PROJECT_HOME=`pwd`
SRCPATH=$PROJECT_HOME
BUILDDIR=$PROJECT_HOME/build
LIBOUTPUTDIR=$PROJECT_HOME/lib/MWFeedParser-iOS

$XCODEBUILD -target "MWFeedParser-iOS" -sdk "iphonesimulator" -configuration "Release" SYMROOT=$BUILDDIR clean build || die "iOS Simulator build failed"
$XCODEBUILD -target "MWFeedParser-iOS" -sdk "iphoneos" -configuration "Release" SYMROOT=$BUILDDIR clean build || die "iOS Device build failed"

# clean up previous build
\rm -rf $LIBOUTPUTDIR
mkdir -p $LIBOUTPUTDIR

# combine lib files for various platforms into one
lipo -create $BUILDDIR/Release-iphonesimulator/libMWFeedParser-iOS.a $BUILDDIR/Release-iphoneos/libMWFeedParser-iOS.a -output $LIBOUTPUTDIR/libMWFeedParser-iOS.a || die "Could not create static output library"

echo "Copy required headers"
\cp $SRCPATH/classes/MWFeedInfo.h $LIBOUTPUTDIR/
\cp $SRCPATH/classes/MWFeedItem.h $LIBOUTPUTDIR/
\cp $SRCPATH/classes/MWFeedParser.h $LIBOUTPUTDIR/

echo "Build completed"
echo "You can now use the static library that can be found at:"
echo ""
echo $LIBOUTPUTDIR
echo ""

exit 0
