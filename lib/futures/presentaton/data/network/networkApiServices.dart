import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:rest_api/futures/presentaton/data/app_exaptions.dart';
import 'package:rest_api/futures/presentaton/data/network/baseApiServices.dart';

class NetworkApiServices extends BaseApiServes {
  @override
  Future getPostApiResponse(String url, dynamic data) async {
    try {
      final response = await http
          .post(Uri.parse(url), body: jsonEncode(data), headers: {
        'Content-Type': 'application/json',
      }).timeout(const Duration(seconds: 10));

      return returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  @override
  Future getResponse(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      return returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorizedException(response.body.toString());
      case 404:
        throw NotFoundException('Resource Not Found');
      case 500:
        throw InternalServerErrorException('Internal Server Error');
      default:
        throw FetchDataException(
            'Error occurred with status code: ${response.statusCode}');
    }
  }
}
