import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fantom/src/utils/exceptions.dart';
import 'package:fantom/src/utils/logger.dart';

class FileDownloader {
  final String fileUrl;
  final String savePath;

  FileDownloader({required this.fileUrl, required this.savePath});

  Future<File> download() async {
    String? content;

    // trying to download file from [fileUrl]
    try {
      Log.info('Downloading file from $fileUrl');
      final options = BaseOptions(
        validateStatus: (status) => (status ?? 400) < 400,
      );
      final dio = Dio(options);
      final response = await dio.get(
        fileUrl,
        options: Options(
          responseType: ResponseType.plain,
        ),
      );
      final encoder = JsonEncoder.withIndent("    ");
      content = encoder.convert(jsonDecode(response.data));
    } catch (e) {
      Log.error(e.toString());
      throw CouldNotDownloadFileException(fileUrl);
    }

    // trying to save file in savePath
    File? openapiFile;
    Log.info('Saving file in $savePath');
    try {
      openapiFile = File(savePath);
      if (!openapiFile.existsSync()) {
        await openapiFile.create(recursive: true);
      }
      await openapiFile.writeAsString(content);
    } catch (e) {
      Log.error(e.toString());
      throw CouldNotSaveFileException(savePath);
    }

    return openapiFile;
  }
}
