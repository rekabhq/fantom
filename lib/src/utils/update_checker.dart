///
/// this code has been copied here from the https://github.com/leoafarias/cli_notify
///
/// since bug fix and some changes where needed
///
/// TODO :  create a pull request to this repo and fix the bug
///
/// TODO :  create a pull request to this repo to allow developer to customzie the update log
///
///
///

import 'dart:convert';

import 'package:fantom/src/utils/logger.dart';

import 'dart:io';

import 'package:tint/tint.dart';

String _packageUrl(String packageName) => 'https://pub.dev/api/packages/$packageName';

String _changelogUrl(String packageName) => 'https://pub.dev/packages/$packageName/changelog';

/// cli update
class UpdateChecker {
  /// Constructor for the update notifier
  const UpdateChecker({
    required this.packageName,
    required this.currentVersion,
    this.verbose = false,
  });

  /// Name of the package you want to notify of update
  final String packageName;

  /// Current version of the package
  final String currentVersion;

  /// Output error logs
  final bool verbose;

  /// Fetches latest version from pub.dev
  Future<String?> _fetchLatestVersion() async {
    final response = await fetch(_packageUrl(packageName));
    final json = jsonDecode(response) as Map<String, dynamic>;
    final version = json['latest']['version'] as String;
    return version;
  }

  /// Prints notice if version needs update
  Future<void> update() async {
    try {
      final latestVersion = await _fetchLatestVersion();
      // Could not get latest version
      if (latestVersion == null) return;
      // Compare semver
      final comparison = compareSemver(currentVersion, latestVersion);
      // Check as need update if latest version is higher
      final needUpdate = comparison < 0;

      if (needUpdate) {
        Log.info('new version of fantom is available');
        final updateCmd = 'pub global activate $packageName'.cyan();
        final current = currentVersion.black().onRed();
        final latest = latestVersion.black().onGreen();

        Log.divider();
        print(
          'Update Available '
          '$current → $latest ',
        );
        print('Run $updateCmd to update');
        print('Changelog: ${_changelogUrl(packageName)}');
        Log.divider();
        return;
      }
      return;
    } on Exception {
      // Don't do anything fail silently
      return;
    }
  }
}

/// Compares a [version] against [other]
/// returns negative if [version] is ordered before
/// positive if [version] is ordered after
/// 0 if its the same
int compareSemver(String version, String other) {
  final regExp = RegExp(
    r'^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(-[a-zA-Z\d][-a-zA-Z.\d]*)?(\+[a-zA-Z\d][-a-zA-Z.\d]*)?$',
  );
  try {
    if (regExp.hasMatch(version) && regExp.hasMatch(other)) {
      final versionMatches = regExp.firstMatch(version);
      final otherMatches = regExp.firstMatch(other);

      var result = 0;

      if (versionMatches == null || otherMatches == null) {
        return result;
      }

      final isPrerelease = otherMatches.group(4) != null ? true : false;
      // Ignore if its pre-release
      if (isPrerelease) {
        return result;
      }

      for (var idx = 1; idx < versionMatches.groupCount; idx++) {
        final versionMatch = versionMatches.group(idx) ?? '';
        final otherMatch = otherMatches.group(idx) ?? '';
        // PreRelease group

        final versionNumber = int.tryParse(versionMatch);
        final otherNumber = int.tryParse(otherMatch);
        if (versionMatch != otherMatch) {
          if (versionNumber == null || otherNumber == null) {
            result = versionMatch.compareTo(otherMatch);
          } else {
            result = versionNumber.compareTo(otherNumber);
          }
          break;
        }
      }

      return result;
    }

    return 0;
  } on Exception catch (err) {
    print(err.toString());
    return 0;
  }
}

/// Does a simple get request on [url]
Future<String> fetch(String url) async {
  final client = HttpClient();
  final request = await client.getUrl(Uri.parse(url));

  final response = await request.close();

  final stream = response.transform(Utf8Decoder());

  var res = '';
  await for (final data in stream) {
    res += data;
  }
  client.close();

  return res;
}
