import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'global.dart';

class HttpHelper {

  /// Invokes an `http` request given.
  /// [url] can either be a `string` or a `Uri`.
  /// The [type] can be any of the [RequestType]s.
  /// [body] and [encoding] only apply to [RequestType.post] and [RequestType.put] requests. Otherwise,
  /// they have no effect.
  /// This is optimized for requests that anticipate a response body of type `Map<String, dynamic>`, as in a json file-type response.
  static Future<Map<String, dynamic>?> invokeHttp(dynamic url, RequestType type,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    http.Response response;
    Map<String, dynamic>? responseBody;
    try {
      response = await _invoke(url, type,
          headers: getHeaders(headers, url),
          body: body,
          encoding: Encoding.getByName("utf-8"));
    } catch (error) {
      rethrow;
    }
    if (response.body.isEmpty) return null;
    responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  /// Invokes an `http` request given.
  /// [url] can either be a `string` or a `Uri`.
  /// The [type] can be any of the [RequestType]s.
  /// [body] and [encoding] only apply to [RequestType.post] and [RequestType.put] requests. Otherwise,
  /// they have no effect.
  /// This is optimized for requests that anticipate a response body of type `Map<String, dynamic>`, as in a json file-type response.
  static Future<List<dynamic>?> invokeHttpList(dynamic url, RequestType type,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    http.Response response;
    List<dynamic>? responseBody;
    try {
      response = await _invoke(url, type,
          headers: getHeaders(headers, url),
          body: body,
          encoding: Encoding.getByName("utf-8"));
    } catch (error) {
      rethrow;
    }
    if (response.body.isEmpty) return null;
    responseBody = jsonDecode(utf8.decode(response.bodyBytes));
    return responseBody;
  }

  /// Invokes an `http` request given.
  /// [url] can either be a `string` or a `Uri`.
  /// The [type] can be any of the [RequestType]s.
  /// [body] and [encoding] only apply to [RequestType.post] and [RequestType.put] requests. Otherwise,
  /// they have no effect.
  /// This is optimized for requests that anticipate a response body of type `Map<String, dynamic>`, as in a json file-type response.


  /// Invokes an `http` request given.
  /// [url] can either be a `string` or a `Uri`.
  /// The [type] can be any of the [RequestType]s.
  /// [body] and [encoding] only apply to [RequestType.post] and [RequestType.put] requests. Otherwise,
  /// they have no effect.
  /// This is optimized for requests that anticipate a response body of type `Map<String, dynamic>`, as in a json file-type response.


  static Map<String, String> getHeaders(Map<String, String>? headers, dynamic url) {
    Map<String, String>? customizeHeaders;
    if (headers != null) {
      customizeHeaders = headers;
    } else {
      customizeHeaders = {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "platform": Platform.isIOS ? "IOS" : "ANDROID",
        // "deviceAppVer": Global.appVersion,
        // "lang": Global.mLang
      };
    }
    return customizeHeaders;
  }

  /// Invokes an `http` request given.
  /// [url] can either be a `string` or a `Uri`.
  /// The [type] can be any of the [RequestType]s.
  /// [body] and [encoding] only apply to [RequestType.post] and [RequestType.put] requests. Otherwise,
  /// they have no effect.
  /// This is optimized for requests that anticipate a response body of type `List<dynamic>`, as in a list of json objects.
  static Future<List<dynamic>> invokeHttp2(dynamic url, RequestType type,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    http.Response response;
    List<dynamic> responseBody;
    try {
      response = await _invoke(url, type,
          headers: headers, body: body, encoding: encoding);
    } on APIException {
      rethrow;
    } on SocketException {
      rethrow;
    }

    responseBody = jsonDecode(response.body);
    return responseBody;
  }

  /// Invoke the `http` request, returning the [http.Response] unparsed.
  static Future<http.Response> _invoke(dynamic url, RequestType type,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    if (!Global.isDisableHttpLogging) {
      debugPrint("MaluHttp: >>>>");
      debugPrint("MaluHttp: Request Url: $url");
      debugPrint("MaluHttp: Request Method: ${type.name.toUpperCase()}");
      debugPrint("MaluHttp: Request Header: ${headers.toString()}");
      debugPrint(
          "MaluHttp: Request Time: ${DateFormat("dd MMMM yyyy HH:mm:ss").format(
              DateTime.now())}");
      debugPrint(
          "MaluHttp: Request body: ${body == null ? "EMPTY" : body
              .toString()}");
      debugPrint("MaluHttp: >>>>");
    }
    http.Response response;

    try {
      switch (type) {
        case RequestType.get:
          response = await http.get(url, headers: headers);
          break;
        case RequestType.post:
          response = await http.post(url,
              headers: headers, body: body, encoding: encoding);
          break;
        case RequestType.put:
          response = await http.put(url,
              headers: headers, body: body, encoding: encoding);
          break;
        case RequestType.delete:
          response = await http.delete(url, headers: headers);
          break;
      }
      if (!Global.isDisableHttpLogging) {
        debugPrint("MaluHttp: <<<<");
        debugPrint("MaluHttp: Response for Url: ${response.statusCode} - $url");
        debugPrint(
            "MaluHttp: Response time: ${DateFormat("dd MMMM yyyy HH:mm:ss")
                .format(DateTime.now())}");
        debugPrint(
            "MaluHttp: Response: ${response.body.isEmpty ? "EMPTY" : response
                .body.toString()}");
        debugPrint("MaluHttp: <<<<");
      }
      // check for any errors
      if (!successStatusCodeList.contains(response.statusCode)) {
        Map<String, dynamic> body = jsonDecode(response.body);
        if (response.statusCode == 500) {
          try {
            String error = "";
            if (body['error'] != null) {
              error = body['error'];
            } else if (body['message'] != null) {
              error = body['message'];
            }
            throw APIException(error, response.statusCode, null);
          } catch (e) {
            String error = "";
            if (body['error'] != null) {
              error = body['error'];
            } else if (body['message'] != null) {
              error = body['message'];
            }
            throw APIException(error, response.statusCode, null);
          }
        } else {
          String error = "";
          if (body['error'] != null) {
            error = body['error'];
          } else if (body['message'] != null) {
            error = body['message'];
          }
          throw APIException(error, response.statusCode, body['statusText']);
        }
      }
      return response;
    } on http.ClientException {
      // handle any 404's
      rethrow;
      // handle no internet connection
    } on SocketException catch (e) {
      throw Exception(e.osError?.message);
    } catch (error) {
      rethrow;
    }
  }

  /// Invoke the `http` request, returning the [http.Response] unparsed.
  static Future<http.Response> _invokeFile(
      dynamic url, RequestType type, List<http.MultipartFile> filePaths,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    if (!Global.isDisableHttpLogging) {
      debugPrint("MaluHttp: >>>>");
      debugPrint("MaluHttp: Request Url: $url");
      debugPrint("MaluHttp: Request Method: ${type.name.toUpperCase()}");
      debugPrint("MaluHttp: Request Header: ${headers.toString()}");
      debugPrint(
          "MaluHttp: Request Time: ${DateFormat("dd MMMM yyyy HH:mm:ss").format(
              DateTime.now())}");
      debugPrint(
          "MaluHttp: Request body: ${body == null ? "EMPTY" : body
              .toString()}");
      debugPrint("MaluHttp: >>>>");
    }

    http.Response response;

    try {
      http.MultipartRequest request =
      http.MultipartRequest(type.name.toUpperCase(), url);
      if (headers != null) {
        request.headers.addAll(headers);
      }
      request.files.addAll(filePaths);
      http.StreamedResponse streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);

      if (!Global.isDisableHttpLogging) {
        debugPrint("MaluHttp: <<<<");
        debugPrint("MaluHttp: Response for Url: ${response.statusCode} - $url");
        debugPrint(
            "MaluHttp: Response time: ${DateFormat("dd MMMM yyyy HH:mm:ss")
                .format(DateTime.now())}");
        debugPrint(
            "MaluHttp: Response: ${response.body.isEmpty ? "EMPTY" : response
                .body.toString()}");
        debugPrint("MaluHttp: <<<<");
      }
      // check for any errors
      if (!successStatusCodeList.contains(response.statusCode)) {
        Map<String, dynamic> body = jsonDecode(response.body);
        if (response.statusCode == 500) {
          try {
            String error = "";
            if (body['error'] != null) {
              error = body['error'];
            } else if (body['message'] != null) {
              error = body['message'];
            }
            throw APIException(error, response.statusCode, null);
          } catch (e) {
            String error = "";
            if (body['error'] != null) {
              error = body['error'];
            } else if (body['message'] != null) {
              error = body['message'];
            }
            throw APIException(error, response.statusCode, null);
          }
        } else {
          String error = "";
          if (body['error'] != null) {
            error = body['error'];
          } else if (body['message'] != null) {
            error = body['message'];
          }
          throw APIException(
              error, response.statusCode, body['statusText']);
        }
      }
      return response;
    } on http.ClientException {
      // handle any 404's
      rethrow;

      // handle no internet connection
    } on SocketException catch (e) {
      throw Exception(e.osError?.message);
    } catch (error) {
      rethrow;
    }
  }

  /// Invoke the `http` request, returning the [http.Response] unparsed.
  static Future<http.Response> _invokeSingleFile(
      dynamic url, RequestType type, http.MultipartFile filePaths,
      {Map<String, String>? headers, dynamic body, Encoding? encoding}) async {
    if (!Global.isDisableHttpLogging) {
      debugPrint("MaluHttp: >>>>");
      debugPrint("MaluHttp: Request Url: $url");
      debugPrint("MaluHttp: Request Method: ${type.name.toUpperCase()}");
      debugPrint("MaluHttp: Request Header: ${headers.toString()}");
      debugPrint(
          "MaluHttp: Request Time: ${DateFormat("dd MMMM yyyy HH:mm:ss").format(
              DateTime.now())}");
      debugPrint(
          "MaluHttp: Request body: ${body == null ? "EMPTY" : body
              .toString()}");
      debugPrint("MaluHttp: >>>>");
    }

    http.Response response;

    try {
      http.MultipartRequest request =
      http.MultipartRequest(type.name.toUpperCase(), url);
      if (headers != null) {
        request.headers.addAll(headers);
      }
      request.files.add(filePaths);
      http.StreamedResponse streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);

      if (!Global.isDisableHttpLogging) {
        debugPrint("MaluHttp: <<<<");
        debugPrint("MaluHttp: Response for Url: ${response.statusCode} - $url");
        debugPrint(
            "MaluHttp: Response time: ${DateFormat("dd MMMM yyyy HH:mm:ss")
                .format(DateTime.now())}");
        debugPrint(
            "MaluHttp: Response: ${response.body.isEmpty ? "EMPTY" : response
                .body.toString()}");
        debugPrint("MaluHttp: <<<<");
      }
      // check for any errors
      if (!successStatusCodeList.contains(response.statusCode)) {
        Map<String, dynamic> body = jsonDecode(response.body);
        if (response.statusCode == 500) {
          try {
            String error = "";
            if (body['error'] != null) {
              error = body['error'];
            } else if (body['message'] != null) {
              error = body['message'];
            }
            throw APIException(error, response.statusCode, null);
          } catch (e) {
            String error = "";
            if (body['error'] != null) {
              error = body['error'];
            } else if (body['message'] != null) {
              error = body['message'];
            }
            throw APIException(error, response.statusCode, null);
          }
        } else {
          String error = "";
          if (body['error'] != null) {
            error = body['error'];
          } else if (body['message'] != null) {
            error = body['message'];
          }
          throw APIException(error, response.statusCode, body['statusText']);
        }
      }
      return response;
    } on http.ClientException {
      // handle any 404's
      rethrow;

      // handle no internet connection
    } on SocketException catch (e) {
      throw Exception(e.osError?.message);
    } catch (error) {
      rethrow;
    }
  }
}

// types used by the helper
enum RequestType { get, post, put, delete }