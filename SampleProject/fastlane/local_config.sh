#!/bin/sh

# This file contains the local values for Fastlane to be able to mimic being
# run on Travis with secure environment variables.
#
# To get fastlane to see the environment variables contained here, run this
# command from your repo root (use both dots or it won't work):
#   . ./fastlane/local_config.sh
#
# More info on this technique:
# http://macoscope.com/blog/automate-testing-and-build-delivery/
#
# NOTE: If variables are securely encrypted, they will not be available on a
#       PR on travis, and anything trying to make use of them will likely fail.
#
# DO NOT COMMIT THIS FILE UNDER PENALTY OF CATAPULT
# https://frinkiac.com/meme/S08E18/1207956.jpg?lines=%22AND+HE+WHO+SHALL+VIOLATE%0ATHIS+LAW+SHALL+BE+PUNISHED%0ABY+CATAPULT.%22


# Currently using a renamed Xcode for 8
export DEVELOPER_DIR="/Applications/Xcode 8.app/Contents/Developer"

