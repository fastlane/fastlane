# !/bin/bash

# Copyright (c) 2011 Float Mobile Learning
# http://www.floatlearning.com/
# Extension Copyright (c) 2013 Weptun Gmbh
# http://www.weptun.de
#
# Extended by Ronan O Ciosoig January 2012
#
# Extended by Patrick Blitz, April 2013
#
# Extended by John Turnipseed and Matthew Nespor, November 2014
# http://nanonation.net/
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# Please let us know about any improvements you make to this script!
# ./floatsign source "iPhone Distribution: Name" -p "path/to/profile" [-d "display name"]  [-e entitlements] [-k keychain] -b "BundleIdentifier" outputIpa
#
#
# Modifed 26th January 2012
#
# new features January 2012:
# 1. change the app display name
#
# new features April 2013
# 1. specify the target bundleId on the command line
# 2. correctly handles entitlements for keychain-enabled resigning
#
# new features November 2014
# 1. now re-signs embedded iOS frameworks, if present, prior to re-signing the application itself
# 2. extracts the team-identifier from provisioning profile and uses it to update previous entitlements
# 3. fixed bug in packaging if -e flag is used
# 4. renamed 'temp' directory and made it a variable so it can be easily modified
# 5. various code formatting and logging adjustments
# 


function checkStatus {

if [ $? -ne 0 ];
then
    echo "Encountered an error, aborting!" >&2
    exit 1
fi
}

if [ $# -lt 3 ]; then
    echo "usage: $0 source identity -p provisioning [-e entitlements] [-r adjustBetaReports] [-d displayName] [-n version] -b bundleId outputIpa" >&2
    echo "       -p and -b are optional, but their use is heavly recommended" >&2
    echo "       -r flag requires a value '-r yes'"
    echo "       -r flag is ignored if -e is also used" >&2
    exit 1
fi

ORIGINAL_FILE="$1"
CERTIFICATE="$2"
NEW_PROVISION=
ENTITLEMENTS=
BUNDLE_IDENTIFIER=""
DISPLAY_NAME=""
APP_IDENTIFER_PREFIX=""
TEAM_IDENTIFIER=""
KEYCHAIN=""
VERSION_NUMBER=""
ADJUST_BETA_REPORTS_ACTIVE_FLAG="0"
TEMP_DIR="_floatsignTemp"

# options start index
OPTIND=3
while getopts p:d:e:k:b:r:n: opt; do
    case $opt in
        p)
            NEW_PROVISION="$OPTARG"
            echo "Specified provisioning profile: '$NEW_PROVISION'" >&2
            ;;
        d)
            DISPLAY_NAME="$OPTARG"
            echo "Specified display name: '$DISPLAY_NAME'" >&2
            ;;
        e)
            ENTITLEMENTS="$OPTARG"
            echo "Specified signing entitlements: '$ENTITLEMENTS'" >&2
            ;;
        b)
            BUNDLE_IDENTIFIER="$OPTARG"
            echo "Specified bundle identifier: '$BUNDLE_IDENTIFIER'" >&2
            ;;
        k)
            KEYCHAIN="$OPTARG"
            echo "Specified Keychain to use: '$KEYCHAIN'" >&2
            ;;
        n)
            VERSION_NUMBER="$OPTARG"
            echo "Specified version to use: '$VERSION_NUMBER'" >&2
            ;;
        r)
            ADJUST_BETA_REPORTS_ACTIVE_FLAG="1"
            echo "Enabled adjustment of beta-reports-active entitlements" >&2
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND-1))

NEW_FILE="$1"
if [ -z "$NEW_FILE" ]; 
then
    echo "Output file name required" >&2
    exit 1
fi


# Check for and remove the temporary directory if it already exists
if [ -d "$TEMP_DIR" ]; 
then
    echo "Removing previous temporary directory: '$TEMP_DIR'" >&2
    rm -Rf "$TEMP_DIR"
fi

filename=$(basename "$ORIGINAL_FILE")
extension="${filename##*.}"
filename="${filename%.*}"

# Check if the supplied file is an ipa or an app file
if [ "${extension}" = "ipa" ]
then
    # Unzip the old ipa quietly
    unzip -q "$ORIGINAL_FILE" -d $TEMP_DIR
    checkStatus
elif [ "${extension}" = "app" ]
then
    # Copy the app file into an ipa-like structure
    mkdir -p "$TEMP_DIR/Payload"
    cp -Rf "${ORIGINAL_FILE}" "$TEMP_DIR/Payload/${filename}.app"
    checkStatus
else
    echo "Error: Only can resign .app files and .ipa files." >&2
    exit
fi

# check the keychain
if [ "${KEYCHAIN}" != "" ];
then
    security list-keychains -s $KEYCHAIN
    security unlock $KEYCHAIN
    security default-keychain -s $KEYCHAIN
fi

# Set the app name
# The app name is the only file within the Payload directory
APP_NAME=$(ls "$TEMP_DIR/Payload/")

# Make sure that PATH includes the location of the PlistBuddy helper tool as its location is not standard
export PATH=$PATH:/usr/libexec

# Make sure that the Info.plist file is where we expect it
if [ ! -e "$TEMP_DIR/Payload/$APP_NAME/Info.plist" ];
then
    echo "Expected file does not exist: '$TEMP_DIR/Payload/$APP_NAME/Info.plist'" >&2
    exit 1;
fi

# Read in current values from the app
CURRENT_NAME=`PlistBuddy -c "Print :CFBundleDisplayName" "$TEMP_DIR/Payload/$APP_NAME/Info.plist"`
CURRENT_BUNDLE_IDENTIFIER=`PlistBuddy -c "Print :CFBundleIdentifier" "$TEMP_DIR/Payload/$APP_NAME/Info.plist"`
if [ "${BUNDLE_IDENTIFIER}" == "" ];
then
    BUNDLE_IDENTIFIER=`egrep -a -A 2 application-identifier "${NEW_PROVISION}" | grep string | sed -e 's/<string>//' -e 's/<\/string>//' -e 's/ //' | awk '{split($0,a,"."); i = length(a); for(ix=2; ix <= i;ix++){ s=s a[ix]; if(i!=ix){s=s "."};} print s;}'`
    if [[ "${BUNDLE_IDENTIFIER}" == *\** ]]; then
        echo "Bundle Identifier contains a *, using the current bundle identifier" >&2
        BUNDLE_IDENTIFIER=$CURRENT_BUNDLE_IDENTIFIER;
    fi
    checkStatus
fi

echo "Current bundle identifier is: '$CURRENT_BUNDLE_IDENTIFIER'" >&2
echo "New bundle identifier will be: '$BUNDLE_IDENTIFIER'" >&2

# Update the CFBundleDisplayName property in the Info.plist if a new name has been provided
if [ "${DISPLAY_NAME}" != "" ];
then
    if [ "${DISPLAY_NAME}" != "${CURRENT_NAME}" ];
    then
        echo "Changing display name from '$CURRENT_NAME' to '$DISPLAY_NAME'" >&2
        `PlistBuddy -c "Set :CFBundleDisplayName $DISPLAY_NAME" "$TEMP_DIR/Payload/$APP_NAME/Info.plist"`
    fi
fi

# Replace the embedded mobile provisioning profile
if [ "$NEW_PROVISION" != "" ];
then
    if [[ -e "$NEW_PROVISION" ]];
    then
        echo "Validating the new provisioning profile: $NEW_PROVISION" >&2
        security cms -D -i "$NEW_PROVISION" > "$TEMP_DIR/profile.plist"
        checkStatus

        APP_IDENTIFER_PREFIX=`PlistBuddy -c "Print :Entitlements:application-identifier" "$TEMP_DIR/profile.plist" | grep -E '^[A-Z0-9]*' -o | tr -d '\n'` 
        if [ "$APP_IDENTIFER_PREFIX" == "" ];
        then
            APP_IDENTIFER_PREFIX=`PlistBuddy -c "Print :ApplicationIdentifierPrefix:0" "$TEMP_DIR/profile.plist"` 
            if [ "$APP_IDENTIFER_PREFIX" == "" ];
            then
                echo "Failed to extract any app identifier prefix from '$NEW_PROVISION'" >&2
                exit 1;
            else
                echo "WARNING: extracted an app identifier prefix '$APP_IDENTIFER_PREFIX' from '$NEW_PROVISION', but it was not found in the profile's entitlements" >&2
            fi
        else
            echo "Profile app identifier prefix is '$APP_IDENTIFER_PREFIX'" >&2
        fi
        
        TEAM_IDENTIFIER=`PlistBuddy -c "Print :Entitlements:com.apple.developer.team-identifier" "$TEMP_DIR/profile.plist" | tr -d '\n'` 
        if [ "$TEAM_IDENTIFIER" == "" ];
        then
            TEAM_IDENTIFIER=`PlistBuddy -c "Print :TeamIdentifier:0" "$TEMP_DIR/profile.plist"` 
            if [ "$TEAM_IDENTIFIER" == "" ];
            then
                echo "Failed to extract team identifier from '$NEW_PROVISION', resigned ipa may fail on iOS 8 and higher" >&2
            else
                echo "WARNING: extracted a team identifier '$TEAM_IDENTIFIER' from '$NEW_PROVISION', but it was not found in the profile's entitlements, resigned ipa may fail on iOS 8 and higher" >&2
            fi
        else
            echo "Profile team identifier is '$TEAM_IDENTIFIER'" >&2
        fi

        cp "$NEW_PROVISION" "$TEMP_DIR/Payload/$APP_NAME/embedded.mobileprovision"
    else
        echo "Provisioning profile '$NEW_PROVISION' file does not exist" >&2
        exit 1;
    fi
else
    echo "-p 'xxxx.mobileprovision' argument is required" >&2
    exit 1;
fi


#if the current bundle identifier is different from the new one in the provisioning profile, then change it.
if [ "$CURRENT_BUNDLE_IDENTIFIER" != "$BUNDLE_IDENTIFIER" ];
then
    echo "Updating the bundle identifier from '$CURRENT_BUNDLE_IDENTIFIER' to '$BUNDLE_IDENTIFIER'" >&2
    `PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_IDENTIFIER" "$TEMP_DIR/Payload/$APP_NAME/Info.plist"`
    checkStatus
fi

# Update the version number properties in the Info.plist if a version number has been provided
if [ "$VERSION_NUMBER" != "" ];
then
    CURRENT_VERSION_NUMBER=`PlistBuddy -c "Print :CFBundleVersion" "$TEMP_DIR/Payload/$APP_NAME/Info.plist"`
    if [ "$VERSION_NUMBER" != "$CURRENT_VERSION_NUMBER" ];
    then
        echo "Updating the version from '$CURRENT_VERSION_NUMBER' to '$VERSION_NUMBER'" >&2
        `PlistBuddy -c "Set :CFBundleVersion $VERSION_NUMBER" "$TEMP_DIR/Payload/$APP_NAME/Info.plist"`
        `PlistBuddy -c "Set :CFBundleShortVersionString $VERSION_NUMBER" "$TEMP_DIR/Payload/$APP_NAME/Info.plist"`
    fi
fi

# Check for and resign any embedded frameworks (new feature for iOS 8 and above apps)
FRAMEWORKS_DIR="$TEMP_DIR/Payload/$APP_NAME/Frameworks"
if [ -d "$FRAMEWORKS_DIR" ];
then
    if [ "$TEAM_IDENTIFIER" == "" ];
    then
        echo "ERROR: embedded frameworks detected, re-signing iOS 8 (or higher) applications wihout a team identifier in the certificate/profile does not work" >&2
        exit 1;
    fi
    
    echo "Resigning embedded frameworks using certificate: '$CERTIFICATE'" >&2
    for framework in "$FRAMEWORKS_DIR"/*
    do
        if [[ "$framework" == *.framework || "$framework" == *.dylib ]]
        then
            /usr/bin/codesign -f -s "$CERTIFICATE" "$framework"
            checkStatus
        else
            echo "Ignoring non-framework: $framework" >&2
        fi
    done
fi


# Resign the application
if [ "$ENTITLEMENTS" != "" ];
then
    if [ -n "$APP_IDENTIFER_PREFIX" ];
    then
        # sanity check the 'application-identifier' is present in the provided entitlements and matches the provisioning profile value 
        ENTITLEMENTS_APP_ID_PREFIX=`PlistBuddy -c "Print :application-identifier" "$ENTITLEMENTS" | grep -E '^[A-Z0-9]*' -o | tr -d '\n'` 
        if [ "$ENTITLEMENTS_APP_ID_PREFIX" == "" ]; 
        then
            echo "Provided entitlements file is missing a value for the required 'application-identifier' key" >&2
            exit 1;
        elif [ "$ENTITLEMENTS_APP_ID_PREFIX" != "$APP_IDENTIFER_PREFIX" ]; 
        then
            echo "Provided entitlements file's app identifier prefix value '$ENTITLEMENTS_APP_ID_PREFIX' does not match the provided provisioning profile's value '$APP_IDENTIFER_PREFIX'" >&2
            exit 1;
        fi
    fi

    if [ -n "$TEAM_IDENTIFIER" ];
    then
        # sanity check the 'com.apple.developer.team-identifier' is present in the provided entitlements and matches the provisioning profile value
        ENTITLEMENTS_TEAM_IDENTIFIER=`PlistBuddy -c "Print :com.apple.developer.team-identifier" "$ENTITLEMENTS" | tr -d '\n'` 
        if [ "$ENTITLEMENTS_TEAM_IDENTIFIER" == "" ]; 
        then
            echo "Provided entitlements file is missing a value for the required 'com.apple.developer.team-identifier' key" >&2
            exit 1;
        elif [ "$ENTITLEMENTS_TEAM_IDENTIFIER" != "$TEAM_IDENTIFIER" ]; 
        then
            echo "Provided entitlements file's 'com.apple.developer.team-identifier' '$ENTITLEMENTS_TEAM_IDENTIFIER' does not match the provided provisioning profile's value '$TEAM_IDENTIFIER'" >&2
            exit 1;
        fi
    fi

    echo "Resigning application using certificate: '$CERTIFICATE'" >&2
    echo "and entitlements: $ENTITLEMENTS" >&2
    /usr/bin/codesign -f -s "$CERTIFICATE" --entitlements="$ENTITLEMENTS" "$TEMP_DIR/Payload/$APP_NAME"
    checkStatus
else
    echo "Extracting existing entitlements for updating" >&2
    /usr/bin/codesign -d --entitlements - "$TEMP_DIR/Payload/$APP_NAME" > "$TEMP_DIR/newEntitlements" 2> /dev/null
    if [ $? -eq 0 ];
    then
        ENTITLEMENTS_TEMP=`cat "$TEMP_DIR/newEntitlements" | sed -E -e '1d'`
        if [ -n "$ENTITLEMENTS_TEMP" ]; then
            echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>$ENTITLEMENTS_TEMP" > "$TEMP_DIR/newEntitlements"
            if [ -s "$TEMP_DIR/newEntitlements" ];
            then
                if [ "$TEAM_IDENTIFIER" != "" ];
                then
                    PlistBuddy -c "Set :com.apple.developer.team-identifier ${TEAM_IDENTIFIER}" "$TEMP_DIR/newEntitlements"
                    checkStatus
                fi
                PlistBuddy -c "Set :application-identifier ${APP_IDENTIFER_PREFIX}.${BUNDLE_IDENTIFIER}" "$TEMP_DIR/newEntitlements"
                checkStatus
                PlistBuddy -c "Set :keychain-access-groups:0 ${APP_IDENTIFER_PREFIX}.${BUNDLE_IDENTIFIER}" "$TEMP_DIR/newEntitlements"
#               checkStatus  -- if this fails it's likely because the keychain-access-groups key does not exist, so we have nothing to update
                if [[ "$CERTIFICATE" == *Distribution* ]]; then
                    IS_ENTERPRISE_PROFILE=`PlistBuddy -c "Print :ProvisionsAllDevices" "$TEMP_DIR/profile.plist" | tr -d '\n'`

                    echo "Assuming Distribution Identity"
                    if [ "$ADJUST_BETA_REPORTS_ACTIVE_FLAG" == "1" ]; then
                        if [ "$IS_ENTERPRISE_PROFILE" == "true" ]; then
                            echo "Ensuring beta-reports-active is not included for Enterprise environment"
                            PlistBuddy -c "Delete :beta-reports-active" "$TEMP_DIR/newEntitlements"
                            checkStatus
                        else
                            echo "Ensuring beta-reports-active is present and enabled"
                            # new beta key is only used for Distribution; might not exist yet, if we were building Development
                            PlistBuddy -c "Add :beta-reports-active bool true" "$TEMP_DIR/newEntitlements"
                            if [ $? -ne 0 ]; then
                                PlistBuddy -c "Set :beta-reports-active YES" "$TEMP_DIR/newEntitlements"
                            fi
                            checkStatus
                        fi
                    fi
                    echo "Setting get-task-allow entitlement to NO"
                    PlistBuddy -c "Set :get-task-allow NO" "$TEMP_DIR/newEntitlements"
                else
                    echo "Assuming Development Identity"
                    if [ "$ADJUST_BETA_REPORTS_ACTIVE_FLAG" == "1" ]; then
                        # if we were building with Distribution profile, we have to delete the beta key
                        echo "Ensuring beta-reports-active is not included"
                        PlistBuddy -c "Delete :beta-reports-active" "$TEMP_DIR/newEntitlements"
                        # do not check status here, just let it fail if entry does not exist
                    fi
                    echo "Setting get-task-allow entitlement to YES"
                    PlistBuddy -c "Set :get-task-allow YES" "$TEMP_DIR/newEntitlements"
                fi
                checkStatus
                plutil -lint "$TEMP_DIR/newEntitlements" > /dev/null
                checkStatus
                echo "Resigning application using certificate: '$CERTIFICATE'" >&2
                echo "using existing entitlements updated with bundle identifier: '$APP_IDENTIFER_PREFIX.$BUNDLE_IDENTIFIER'" >&2
                if [ "$TEAM_IDENTIFIER" != "" ];
                then
                    echo "and team identifier: '$TEAM_IDENTIFIER'" >&2
                fi
                /usr/bin/codesign -f -s "$CERTIFICATE" --entitlements="$TEMP_DIR/newEntitlements" "$TEMP_DIR/Payload/$APP_NAME"
                checkStatus
            else
                echo "Failed to create required intermediate file" >&2
                exit 1;
            fi
        else
            echo "No entitlements found" >&2
            echo "Resigning application using certificate: '$CERTIFICATE'" >&2
            echo "without entitlements" >&2
            /usr/bin/codesign -f -s "$CERTIFICATE" "$TEMP_DIR/Payload/$APP_NAME"
            checkStatus
        fi
    else
        echo "Failed to extract entitlements" >&2
        echo "Resigning application using certificate: '$CERTIFICATE'" >&2
        echo "without entitlements" >&2
        /usr/bin/codesign -f -s "$CERTIFICATE" "$TEMP_DIR/Payload/$APP_NAME"
        checkStatus
    fi
fi

# Remove the temporary files if they were created before generating ipa
rm -f "$TEMP_DIR/newEntitlements"
rm -f "$TEMP_DIR/profile.plist"

# Repackage quietly
echo "Repackaging as $NEW_FILE" >&2

# Zip up the contents of the "$TEMP_DIR" folder
# Navigate to the temporary directory (sending the output to null)
# Zip all the contents, saving the zip file in the above directory
# Navigate back to the orignating directory (sending the output to null)
pushd "$TEMP_DIR" > /dev/null
zip -qr "../$TEMP_DIR.ipa" *
popd > /dev/null

# Move the resulting ipa to the target destination
mv "$TEMP_DIR.ipa" "$NEW_FILE"

# Remove the temp directory
rm -rf "$TEMP_DIR"

echo "Process complete" >&2