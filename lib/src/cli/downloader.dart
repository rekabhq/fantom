import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fantom/src/utils/exceptions.dart';
import 'package:fantom/src/utils/logger.dart';
import 'package:fantom/src/utils/utililty_functions.dart';

class FileDownloader {
  final String fileUrl;
  final String? savePath;

  FileDownloader({required this.fileUrl, required this.savePath});

  Future<Map<String, dynamic>> download() async {
    String? content;

    // trying to download file from [fileUrl]
    try {
      Log.info('Downloading file from $fileUrl');
      final options = BaseOptions(
        validateStatus: (status) => (status ?? 400) < 400,
      );
      final dio = Dio(options);
      final response = await dio.get(fileUrl);
      content = response.data.toString();
    } catch (e) {
      Log.error(e.toString());
      throw CouldNotDownloadFileException(fileUrl);
    }

    // trying to save file in savePath

    if (savePath != null) {
      Log.info('Saving file in $savePath');
      try {
        final openapiFile = File(savePath!);
        await openapiFile.writeAsString(content);
      } catch (e) {
        Log.error(e.toString());
        throw CouldNotSaveFileException(savePath!);
      }
    }

    return readJsonOrYaml(content);
  }
}
