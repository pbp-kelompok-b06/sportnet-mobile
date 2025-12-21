import 'package:dio/dio.dart';

class ApiClient {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: "https://anya-aleena-sportnet.pbp.cs.ui.ac.id",
    ),
  )..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.extra['withCredentials'] = true; // 🔥 INI KUNCI WEB
          return handler.next(options);
        },
      ),
    );
}
