import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  static String? baseURL = dotenv.env['base_url'];
}