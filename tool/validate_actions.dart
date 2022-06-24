import 'dart:io';

void main(List<String> args) {
  const actionsFile = '.github/workflows/build.yaml';

  var packages = Directory('packages')
      .listSync()
      .whereType<Directory>()
      .map((d) => d.path.substring(d.path.lastIndexOf('/') + 1))
      .toList()
    ..sort();

  print('Validating $actionsFile ...\n');

  var failed = false;
  var lines =
      File(actionsFile).readAsLinesSync().map((line) => line.trim()).toSet();

  // Here, we look for `- package-name`. This will catch a few additional
  // matches we don't care about, like `- stable`; that won't be an issue in
  // terms of validating that we're testing all packages.
  for (var package in packages) {
    if (lines.contains('- $package')) {
      print("  found configuration: '- $package'");
    } else {
      print("missing configuration: '- $package'");
      failed = true;
    }
  }

  if (failed) {
    exitCode = 1;
    print('\nPlease add missing packages to $actionsFile.');
  } else {
    print('\nNo issues found!');
  }
}
