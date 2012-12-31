#!/bin/bash -e

#
# RH prerequisites:
#   1. sudo yum install git
#

function realpath { echo $(cd $(dirname $1); pwd)/$(basename $1); }

REPODIR=$(dirname $(realpath $0))
TMPDIR=/tmp
CRYPTED_REPODIR=$(dirname $REPODIR)/gcrypt-$(basename $REPODIR)
GIT_REMOTE_GCRYPT_DIR=$TMPDIR/git-remote-gcrypt

ORIGIN_URI=$(git remote -v |grep origin|awk -F ' ' '{print $2}' |head -1)
echo "Import repository key..."
set +e
gpg --import-ownertrust $REPODIR/trust
gpg --allow-secret-key-import --import $REPODIR/key
set -e

if [ -x "$(which git-remote-gcrypt)" ] ; then
  echo "git-remote-gcrypt already installed. Skipping..."
else
echo "Installing git-remote-gcrypt..."
  if [ -d $GIT_REMOTE_GCRYPT_DIR -a "x" != "x${GIT_REMOTE_GCRYPT_DIR}" ]; then
    echo "Cleaning up existing $GIT_REMOTE_GCRYPT_DIR..."
    rm -rf $GIT_REMOTE_GCRYPT_DIR
  fi
  git clone https://github.com/joeyh/git-remote-gcrypt $GIT_REMOTE_GCRYPT_DIR
  cd $GIT_REMOTE_GCRYPT_DIR
  sudo ./install.sh
fi

echo "Starting gpg-agent..."
source $REPODIR/.extra

echo "Cloning gcrypt repository into $CRYPTED_REPODIR..."
git clone gcrypt::$ORIGIN_URI $CRYPTED_REPODIR
cd $CRYPTED_REPODIR

echo "Calling decrypted setup.sh..."
./setup.sh
