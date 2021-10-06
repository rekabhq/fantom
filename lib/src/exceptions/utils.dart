import 'package:fantom/src/exceptions/base.dart';
import 'package:fantom/src/utils/logger.dart';

void handleExceptions(e, stacktrace) {
  if (e is FantomException) {
    Log.error('❌❌ ${e.message}');
  } else {
    Log.error(e.toString());
    Log.error(stacktrace.toString());
  }
}
