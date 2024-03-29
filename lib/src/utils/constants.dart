import 'dart:io';

import 'package:version/version.dart';

final kCurrentDirectory = Directory.current;

final kDefaultModelsOutputPath =
    '${Directory.current.path}/lib/src/fantom/model';

final kDefaultApisOutputPath = '${Directory.current.path}/lib/src/fantom/api';

const kCliName = 'fantom';

final kMinOpenapiSupportedVersion = Version(3, 0, 0);

final kMaxOpenapiSupportedVersion = Version(3, 1, 0);

const kPackageName = 'fantom';

const kCurrentVersion = '0.0.1';

const kDefaultGeneratedPackageName = 'FantomApi';

const kFantomFileHeader = '''/// Generated code: do not edit by hand.

/// Generated using Fantom.
/// https://pub.dev/packages/fantom

// ignore_for_file: unused_import

''';
