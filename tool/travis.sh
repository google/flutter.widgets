#!/bin/bash

# Make sure dartfmt is run on everything
echo "Checking dartfmt..."
NEEDS_DARTFMT="$(dartfmt -n packages tool)"
if [[ ${NEEDS_DARTFMT} != "" ]]
then
  echo "FAILED"
  echo "${NEEDS_DARTFMT}"
  exit 1
fi
echo "PASSED"

# Make sure we pass the analyzer
echo "Checking dartanalyzer..."
FAILS_ANALYZER="$(find packages tool -name "*.dart" | xargs dartanalyzer --options .analysis_options)"
if [[ $FAILS_ANALYZER == *"[error]"* ]]
then
  echo "FAILED"
  echo "${FAILS_ANALYZER}"
  exit 1
fi
echo "PASSED"

# Fast fail the script on failures.
set -e

# Run the tests.
echo "Running tests in each package..."
for package in $(ls -1 packages); do
  pushd packages/$package
  flutter test
  popd
done
