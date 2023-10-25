import 'package:data_management/core.dart';
import 'package:flutter_andomie/core.dart';

class ApiManager extends Api {
  static const _baseUrl = 'INTERNAL_APPLICATION_BASE_URL';

  static ApiManager get I => instance;

  static ApiManager get instance => getInstance(_baseUrl);

  static ApiManager getInstance(String baseUrl) {
    return Singleton.instanceOf(() => ApiManager._init(api: baseUrl));
  }

  const ApiManager._init({
    required super.api,
  });
}
