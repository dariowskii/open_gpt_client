import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:open_gpt_client/models/local_data.dart';
import 'package:http/http.dart' as http;

/// The [ApiService] interface defines the contract for the [ApiClient].
abstract class ApiService {

  /// The [sendMessages] method sends the messages of the selected [chat] to the OpenAI API.
  Future<Stream<String>?> sendMessages(Chat chat);

  /// The [checkUpdate] method checks if there is an update of the app.
  Future<bool?> checkUpdate();
}

/// The [ApiClient] class defines the client of the OpenAI API.
class ApiClient implements ApiService {
  @override
  Future<Stream<String>?> sendMessages(Chat chat) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient
          .postUrl(Uri.parse('https://api.openai.com/v1/chat/completions'));
      request.headers.set('content-type', 'application/json;charset=UTF-8');
      request.headers
          .set('Authorization', 'Bearer ${(await LocalData.instance.apiKey)!}');
      final messages = chat.contextMessagesJson();
      request.add(
        utf8.encode(
          json.encode(
            {
              'stream': true,
              "model": "gpt-3.5-turbo-0301",
              "messages": messages,
            },
          ),
        ),
      );
      final response = await request.close();

      if (response.statusCode != 200) {
        return null;
      }

      final stream = response
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .transform(
        StreamTransformer<String, String>.fromHandlers(
          handleData: (data, sink) {
            try {
              if (data.isNotEmpty) {
                final json =
                    '{${data.substring(data.indexOf('"id":'), data.lastIndexOf('}') + 1).replaceFirst('data: ', '')}';
                sink.add(json);
              }
            } catch (e) {
              debugPrint(data);
            }
          },
        ),
      );

      httpClient.close();
      return stream;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  @override
  Future<bool> checkUpdate() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://api.github.com/repos/dariowskii/open_gpt_client/releases/latest',
        ),
        headers: {
          'Accept': 'application/vnd.github+json',
          'Authorization': 'Bearer ${LocalData.instance.ghKey!}',
          'X-GitHub-Api-Version': '2022-11-28',
        },
      );

      if (response.statusCode != 200) {
        return false;
      }

      final json = jsonDecode(response.body);
      final version = (json['tag_name'] as String).replaceFirst('v', '');
      // TODO: Change this to the current version of the app.
      return version != '0.0.1';
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }
}
