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
      File(actionsFile).readAsLinesSync().map((line) => line.trim()).toList();

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
