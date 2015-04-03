#!/bin/bash

DESTINATION="/tmp/"
BASE_TEMP="/tmp/"
SOURCE_DIR="$BASE_TEMP/phpipam/sources"

usage() { 
  echo "Usage: $0 -v <version> [-d <destination>]"
}

while getopts ":v:d:" opt; do
  case $opt in
    v)
      VERSION=$OPTARG
      ;;
    d)
      DESTINATION=$OPTARG
      ;;
    h)
      usage
      exit
      ;;
    \?)
      echo "Unknown option: -$OPTARG" >&2
      exit 1
      ;;
    :)
      echo "Missing option argument for -$OPTARG" >&2
      exit 1
      ;;
    *)
      echo "Unimplemented option: -$OPTARG" >&2;
      exit 1
     ;;
  esac
done


if [ -z "$VERSION" ]; then
  usage
  exit 1
fi

URL="http://sourceforge.net/projects/phpipam/files/phpipam-$VERSION.tar/download"

setup_temp() {
  TEMP="$BASE_TEMP/phpipam/phpipam_$VERSION"

  mkdir -p $SOURCE_DIR/phpipam-$VERSION
  mkdir -p $TEMP/DEBIAN
  mkdir -p $TEMP/etc/apache2/conf.d
  mkdir -p $TEMP/usr/share/phpipam
}

fetch() {
  wget -O $SOURCE_DIR/phpipam-$VERSION.tar $URL
  mkdir -p $SOURCE_DIR/phpipam-$VERSION
}

unpack_tar() {
  tar -xvf $SOURCE_DIR/phpipam-$VERSION.tar -C $SOURCE_DIR/phpipam-$VERSION
}

move_files() {
  mv $SOURCE_DIR/phpipam-$VERSION/phpipam/config.php $TEMP/etc/phpipam.conf
  chmod 644 $TEMP/etc/phpipam.conf

  mv $SOURCE_DIR/phpipam-$VERSION/phpipam/* $TEMP/usr/share/phpipam/
  mv $SOURCE_DIR/phpipam-$VERSION/phpipam/.htaccess $TEMP/usr/share/phpipam/

  ln -s /etc/phpipam.conf $TEMP/usr/share/phpipam/config.php 
}

debian_files() {

  cp ./templates/conffiles $TEMP/DEBIAN/conffiles
  cp ./templates/control $TEMP/DEBIAN/control
  cp ./templates/postinst $TEMP/DEBIAN/postinst

  sed -i "s/\$VERSION/$VERSION/" $TEMP/DEBIAN/control
}

build() {
  dpkg-deb --build $TEMP
  mv $BASE_TEMP/phpipam/phpipam_$VERSION.deb $DESTINATION
}

cleanup() {
  rm -rf $TEMP
  rm -rf $SOURCE_DIR/phpipam-$VERSION
  rm -rf $SOURCE_DIR/phpipam-$VERSION.tar
}

run() {
  setup_temp
  fetch
  unpack_tar
  move_files
  debian_files
  build
  cleanup
}

run
