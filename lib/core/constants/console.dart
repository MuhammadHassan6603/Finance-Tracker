import 'package:flutter/foundation.dart';

enum DebugType { error, info, url, response, statusCode, database }

console(dynamic value, {String name = '', DebugType type = DebugType.info}) {
  switch (type) {
    case DebugType.database:
      debugPrint('\x1B[35m${"🗃️ DATABASE $name: $value"}\x1B[0m');
      break;
    case DebugType.statusCode:
      debugPrint('\x1B[33m${"💎 STATUS CODE $name: $value"}\x1B[0m');
      break;

    case DebugType.info:
      debugPrint('\x1B[32m${"⚡ INFO $name: $value"}\x1B[0m');
      break;

    case DebugType.error:
      debugPrint('\x1B[31m${"🚨 ERROR $name: $value"}\x1B[0m');
      break;

    case DebugType.response:
      debugPrint('\x1B[36m${"💡 RESPONSE $name: $value"}\x1B[0m');
      break;

    case DebugType.url:
      debugPrint('\x1B[34m${"📌 URL $name: $value"}\x1B[0m');
      break;
  }
}
