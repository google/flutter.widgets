#!/bin/bash

# Fast fail the script on failures.
set -e

shopt -s globstar nullglob

# Make sure the formatter is run on everything
echo "Checking formatting..."
flutter format --dry-run --set-exit-if-changed packages tool
echo "PASSED"
echo

# Make sure we pass the analyzer
echo "Checking dartanalyzer..."
for package_pubspec in packages/**/pubspec.yaml ; do
  package_dir=$(dirname "${package_pubspec}")
  echo "${package_dir}"
  pushd "${package_dir}" > /dev/null
  flutter analyze
  popd > /dev/null
  echo
done
echo "PASSED"
echo

# Run the tests.
echo "Running tests in each package..."
for test_dir in packages/**/test/ ; do
  echo "${test_dir}"
  pushd "${test_dir}/.." > /dev/null
  flutter test
  popd > /dev/null
  echo
done
