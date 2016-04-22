#!/bin/bash

print_msg() {
  echo "---- $1 ----"
}

error() {
  printf "***** BUILD FAILED *****\nReason: $1\n"
  exit
}

contains() {
  local search="${1}"
  shift
  for element in "${@}"
  do
      if [ "$element" == "$search" ] ; then
          return 1
      fi
  done
  return 0
}

build_iOS() {
  print_msg "Building iOS dependencies"
  carthage update --platform iOS --no-use-binaries
  printf "** Build done **\n\n"
}

build_OSX() {
  print_msg "Building OS X dependencies"
  carthage update --platform OSX --no-use-binaries
  printf "** Build done **\n\n"
}

build_tvOS() {
  print_msg "Building tvOS dependencies"
  carthage update Alamofire RxSwift --platform tvOS --no-use-binaries
  printf "** Build done **\n\n"
}

build_watchOS() {
    print_msg "Building watchOS dependencies"
    carthage update Alamofire RxSwift --platform watchOS --no-use-binaries
    printf "** Build done **\n\n"
}

platforms=("iOS" "OSX" "tvOS" "watchOS")
build_all() {
  for platform in ${platforms[@]}
  do
    eval "build_$platform"
  done
}

if [ "$1" == --platform ]
then
  IFS=, read -a opts <<< "$2"
  eval unique_r=($(printf "%q\n" "${opts[@]}" | sort -u))
  for platform in "${unique_r[@]}"
  do
    if contains "$platform" "${platforms[@]}" == 0;
    then
      error "Command $platform not found\n"
    fi
    eval "build_$platform"
  done
else
  build_all
fi
