import 'dart:io';

void main(List<String> args) {
  var packages = Directory('packages')
      .listSync()
      .whereType<Directory>()
      .map((d) => Package(d))
      .toList()
    ..sort();

  print('Package | Description | Version');
  print('--- | --- | ---');
  for (var package in packages) {
    print(
      '[${package.name}](${package.path}/) | '
      '${package.description} | '
      '[![pub package](https://img.shields.io/pub/v/${package.name}.svg)]'
      '(https://pub.dev/packages/${package.name})',
    );
  }
}

class Package implements Comparable<Package> {
  final Directory dir;

  Package(this.dir);

  String get name => dir.path.substring(dir.path.lastIndexOf('/') + 1);

  String get path => dir.path;

  String get description {
    // An quick and dirty yaml parser (this script doesn't currently have access
    // to a pubspec).
    var pubspec = File('${dir.path}/pubspec.yaml');
    var contents = pubspec.readAsStringSync();
    contents = contents.replaceAll('>\n', '');
    var lines = contents.split('\n');
    return lines
        .firstWhere((line) => line.startsWith('description:'))
        .substring('description:'.length)
        .trim();
  }

  @override
  int compareTo(Package other) => name.compareTo(other.name);
}
