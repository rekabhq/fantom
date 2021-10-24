import 'package:fantom/src/utils/process_manager.dart';
// import 'package:pubspec_yaml/pubspec_yaml.dart' as pubspec;
import 'package:version/version.dart';

class DartPackageInfo {
  final String name;
  final String generationPath;
  final PubspecInfo pubspecInfo;

  DartPackageInfo({
    required this.name,
    required this.generationPath,
    required this.pubspecInfo,
  });
}

class PubspecInfo {
  final Version version;
  final String description;
  final Map<String, dynamic> environment;
  final Map<String, dynamic> dependencies;

  PubspecInfo({
    required this.version,
    required this.description,
    required this.environment,
    required this.dependencies,
  });

  Map<String, dynamic> toJson() {
    return {
      "version": version.toString(),
      "decription": description,
      "environment": environment,
      "dependencies": dependencies,
    };
  }

}

Future createDartPackage(DartPackageInfo packageInfo) async {
  await runFromCmd('mkdir', args: ['-p', (packageInfo.generationPath)]);
  await runFromCmd(
    'dart',
    args: ['create', '${packageInfo.generationPath}/${packageInfo.name}','--template=package-simple'],
  );
}
