import 'dart:async';
import 'package:dio/dio.dart';
import '../util/log.dart';
import '../config/constants.dart';
import 'main_interceptor.dart';

class Api {
  Api() {
    _dio = Dio();
    _dio?.interceptors.add(MainInterceptor());
  }

  Dio? _dio;

  Future<String> sendMessageToOpenAI(String userInput) async {
    try {
      final response = await _dio?.post(
        apiUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization':
                'Bearer $apiKey',
          },
        ),
        data: {
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': 'You are a helpful assistant.'},
            {'role': 'user', 'content': userInput},
          ],
        },
      );

      if (response?.statusCode == 200) {
        final message = response?.data['choices'][0]['message']['content'];
        return message.trim();
      } else {
        throw OpenAIRequestError(
            'Error: ${response?.statusMessage} (${response?.statusCode})');
      }
    } catch (e) {
      l('OpenAI API request failed', e.toString());
      throw OpenAIRequestError(
          'Error: Unable to fetch response. Check your network and API key.');
    }
  }
}

class OpenAIRequestError implements Exception {
  final String message;
  OpenAIRequestError(this.message);

  @override
  String toString() => message;
}
