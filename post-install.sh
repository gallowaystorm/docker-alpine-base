#!/usr/bin/env sh

# fail if a command fails
set -e
set -o pipefail

# set rx to all directories, except data directory/
find "$APP_HOME_DIR" -type d -exec chmod 500 {} +

# set r to all files
find "$APP_HOME_DIR" -type f -exec chmod 400 {} +
chmod -R u=rwx "$DATA_DIR/"

# chown all app files
chown $APP_USER:$APP_USER -R $APP_HOME_DIR $DATA_DIR

# finally remove this file
rm "$0"