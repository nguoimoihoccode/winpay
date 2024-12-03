

import 'package:winpay/entities/add_money_request.dart';

class Global {
  static String email = "";
  static String activatedKey = "";
  static String? _token;

  static String? get token => _token;

  static void setToken(String? value) {
    _token = value;
  }

  static void clearToken() {
    _token = null;
  }

  static bool isDisableHttpLogging = false;

  static AddMoneyRequest moneyRequest = AddMoneyRequest.buildDefault();

  static TransferMoneyRequest transferMoneyRequest = TransferMoneyRequest.buildDefault();
}

const successStatusCodeList = [200, 202, 204];

class APIException implements Exception {
  final String message;
  final int statusCode;
  final String? statusText;

  APIException(this.message, this.statusCode, this.statusText);
}