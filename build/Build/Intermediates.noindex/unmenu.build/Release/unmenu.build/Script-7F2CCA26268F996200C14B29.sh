#!/bin/sh
if which swiftlint >/dev/null; then
  # swiftlint
  echo "skipping swiftlint"
else
  echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi

