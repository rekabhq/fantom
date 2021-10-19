import 'dart:io';

import 'package:version/version.dart';

final kCurrentDirectory = Directory.current;

final kDefaultModelsOutputPath =
    '${Directory.current.path}/lib/src/fantom/model';

final kDefaultApisOutputPath = '${Directory.current.path}/lib/src/fantom/api';

const kCliName = 'fantom';

final kMinOpenapiSupportedVersion = Version(3, 0, 0);

const kPackageName = 'fantom';

const kCurrentVersion = '0.0.1';
