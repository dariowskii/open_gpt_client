import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_gpt_client/extensions/number_extension.dart';
import 'package:open_gpt_client/models/app_settings.dart';
import 'package:open_gpt_client/models/chat.dart';
import 'package:open_gpt_client/utils/app_bloc.dart';
import 'package:open_gpt_client/utils/constants.dart';
import 'package:uuid/uuid.dart';

Map<String, dynamic> parseJson(String text) {
  final json = jsonDecode(text);
  return json;
}

String encodeJson(Map<String, dynamic> json) {
  final text = jsonEncode(json);
  return text;
}

Uint8List decodeBase64(String data) {
  final dataBytes = base64Decode(data);
  return dataBytes;
}

Image getImageFromBase64(String data) {
  final dataImage = base64Decode(data);
  final image = Image.memory(
    dataImage,
    fit: BoxFit.cover,
  );

  return image;
}

Image getImageFromBytes(Uint8List data) {
  final image = Image.memory(
    data,
    fit: BoxFit.cover,
  );

  return image;
}

ChatImage getChatImageFromBase64(Map<String, dynamic> args) {
  final prompt = args['prompt'] as String;
  final data = args['data'] as String;
  final size = args['size'] as DallEImageSize;
  final dataImage = base64Decode(data);
  final imageSize = dataImage.lengthInBytes.filesize();

  final image = ChatImage(
    id: const Uuid().v4(),
    prompt: prompt,
    size: size,
    imageBytes: dataImage,
    imageSize: imageSize,
  );

  return image;
}

/// The [concurrentGetEncryptTestPhrase] function gets the encrypted test phrase from the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [encrypter] - the encrypter for decrypting the test phrase.
///  * [iv] - the initialization vector for decrypting the test phrase.
///  * [documentsPath] - the path to the documents directory.
Future<String?> concurrentGetEncryptTestPhrase(
    Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;
  final documentsPath = args['documentsPath'] as Directory;

  final testPhrasePath = '${documentsPath.path}/test_phrase_encrypted.txt';

  try {
    final testPhraseFile = File(testPhrasePath);
    final testPhrase = testPhraseFile.readAsStringSync();
    final decryptedTestPhrase = encrypter.decrypt64(testPhrase, iv: iv);
    return decryptedTestPhrase;
  } on FileSystemException catch (e) {
    debugPrint(e.toString());
    return null;
  } catch (e) {
    return "-1";
  }
}

/// The [concurrentSetEncryptTestPhrase] function sets the encrypted test phrase in the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [encrypter] - the encrypter for encrypting the test phrase.
///  * [iv] - the initialization vector for encrypting the test phrase.
///  * [documentsPath] - the path to the documents directory.
Future<void> concurrentSetEncryptTestPhrase(Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;
  final documentsPath = args['documentsPath'] as Directory;

  final testPhrasePath = '${documentsPath.path}/test_phrase_encrypted.txt';

  try {
    var testPhraseFile = File(testPhrasePath);
    if (!testPhraseFile.existsSync()) {
      testPhraseFile.createSync(
        recursive: true,
        exclusive: true,
      );
    }

    final encryptedTestPhrase = encrypter
        .encrypt(
          Constants.keys.testPhrase,
          iv: iv,
        )
        .base64;
    testPhraseFile.writeAsStringSync(encryptedTestPhrase);
  } catch (e) {
    debugPrint(e.toString());
  }
}

/// The [concurrentSaveChat] function saves the chat in the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [encrypter] - the encrypter for encrypting the chat.
///  * [iv] - the initialization vector for encrypting the chat.
///  * [chat] - the chat to be saved.
///  * [documentsPath] - the path to the documents directory.
Future<void> concurrentSaveChat(Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;

  final chat = args['chat'] as Chat;
  final documentsPath = args['documentsPath'] as Directory;
  final chatPath = '${documentsPath.path}/chats';

  try {
    final dir = Directory(chatPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    var chatFile = File('$chatPath/chat-${chat.id}.txt');

    if (!chatFile.existsSync()) {
      chatFile.createSync(
        recursive: true,
        exclusive: true,
      );
    }

    final chatJson = jsonEncode(chat);
    final encryptedChat = encrypter.encrypt(chatJson, iv: iv).base64;
    chatFile.writeAsStringSync(encryptedChat);
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> concurrentSaveAllChats(Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;
  final documentsPath = args['documentsPath'] as Directory;
  final appState = args['appState'] as Map<String, dynamic>;
  final chats = (appState['chats'] as List<dynamic>)
      .map((chat) => Chat.fromJson(chat))
      .toList();

  final chatPath = '${documentsPath.path}/chats';

  try {
    final dir = Directory(chatPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    for (var chat in chats) {
      var chatFile = File('$chatPath/chat-${chat.id}.txt');

      if (!chatFile.existsSync()) {
        chatFile.createSync(
          recursive: true,
          exclusive: true,
        );
      }

      final chatJson = jsonEncode(chat);
      final encryptedChat = encrypter.encrypt(chatJson, iv: iv).base64;
      chatFile.writeAsStringSync(encryptedChat);
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

Future<void> concurrentMigrateFromPrefs(Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;
  final documentsPath = args['documentsPath'] as Directory;

  final appState = args['appState'] as String;
  final apiKey = args['apiKey'] as String?;
  final selectedChatId = args['selectedChatId'] as String?;

  final appStateJson = jsonDecode(encrypter.decrypt64(appState, iv: iv));
  final apiKeyDecripted =
      apiKey == null ? null : encrypter.decrypt64(apiKey, iv: iv);
  final selectedChatIdDecrypted = selectedChatId == null
      ? null
      : encrypter.decrypt64(selectedChatId, iv: iv);

  final appSettings = AppSettings(
    apiKey: apiKeyDecripted,
    selectedChatId: selectedChatIdDecrypted,
  );

  await concurrentSetEncryptTestPhrase({
    'encrypter': encrypter,
    'iv': iv,
    'documentsPath': documentsPath,
  });
  await concurrentSaveAllChats({
    'encrypter': encrypter,
    'iv': iv,
    'documentsPath': documentsPath,
    'appState': appStateJson,
  });
  await concurrentSaveAppSettings({
    'encrypter': encrypter,
    'iv': iv,
    'documentsPath': documentsPath,
    'appSettings': appSettings,
  });
}

/// The [concurrentSaveImage] function saves the image in the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [encrypter] - the encrypter for encrypting the image.
///  * [iv] - the initialization vector for encrypting the image.
///  * [image] - the image to be saved.
///  * [documentsPath] - the path to the documents directory.
Future<void> concurrentSaveImage(Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;

  final image = args['image'] as ChatImage;
  final documentsPath = args['documentsPath'] as Directory;
  final imagePath = '${documentsPath.path}/images';

  try {
    final dir = Directory(imagePath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    var imageFile = File('$imagePath/image-${image.id}.txt');

    if (!imageFile.existsSync()) {
      imageFile.createSync(
        recursive: true,
        exclusive: true,
      );
    }

    final imageJson = jsonEncode(image);
    final encryptedImage = encrypter.encrypt(imageJson, iv: iv).base64;
    imageFile.writeAsStringSync(encryptedImage);
  } catch (e) {
    debugPrint(e.toString());
  }
}

/// The [concurrentSaveAppSettings] function saves the app settings in the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [encrypter] - the encrypter for encrypting the app settings.
///  * [iv] - the initialization vector for encrypting the app settings.
///  * [appSettings] - the app settings to be saved.
///  * [documentsPath] - the path to the documents directory.
Future<void> concurrentSaveAppSettings(Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;

  final appSettings = args['appSettings'] as AppSettings;
  final documentsPath = args['documentsPath'] as Directory;
  final appSettingsPath = '${documentsPath.path}/settings.txt';

  try {
    var appSettingsFile = File(appSettingsPath);

    if (!appSettingsFile.existsSync()) {
      appSettingsFile.createSync(
        recursive: true,
        exclusive: true,
      );
    }

    final appSettingsJson = jsonEncode(appSettings);
    final encryptedAppSettings =
        encrypter.encrypt(appSettingsJson, iv: iv).base64;
    appSettingsFile.writeAsStringSync(encryptedAppSettings);
  } catch (e) {
    debugPrint(e.toString());
  }
}

/// The [concurrentGetChats] function gets the chats from the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [encrypter] - the encrypter for decrypting the chats.
///  * [iv] - the initialization vector for decrypting the chats.
///  * [documentsPath] - the path to the documents directory.
Future<List<Chat>> concurrentGetChats(Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;

  final documentsPath = args['documentsPath'] as Directory;
  final chatPath = '${documentsPath.path}/chats';

  try {
    final chatFiles = Directory(chatPath).listSync().toList();
    final chatList = <Chat>[];

    for (final chatFile in chatFiles) {
      final chatJsonBytes = File(chatFile.path).readAsBytesSync();
      final chatJson = utf8.decode(chatJsonBytes);
      final decrypted = encrypter.decrypt64(chatJson, iv: iv);
      final chat = Chat.fromJson(jsonDecode(decrypted));
      chatList.add(chat);
    }

    return chatList;
  } catch (e) {
    debugPrint(e.toString());
    return [];
  }
}

/// The [concurrentGetImages] function gets the images from the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [encrypter] - the encrypter for decrypting the images.
///  * [iv] - the initialization vector for decrypting the images.
///  * [documentsPath] - the path to the documents directory.
Future<List<ChatImage>> concurrentGetImages(Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;

  final documentsPath = args['documentsPath'] as Directory;
  final imagePath = '${documentsPath.path}/images';

  try {
    final imageFiles = Directory(imagePath).listSync().toList();
    final imageList = <ChatImage>[];

    for (final imageFile in imageFiles) {
      final imageJsonBytes = File(imageFile.path).readAsBytesSync();
      final imageJson = utf8.decode(imageJsonBytes);
      final decrypted = encrypter.decrypt64(imageJson, iv: iv);
      final image = ChatImage.fromJson(jsonDecode(decrypted));
      imageList.add(image);
    }

    return imageList;
  } catch (e) {
    debugPrint(e.toString());
    return [];
  }
}

/// The [concurrentGetAppSettings] function gets the app settings from the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [encrypter] - the encrypter for decrypting the app settings.
///  * [iv] - the initialization vector for decrypting the app settings.
///  * [documentsPath] - the path to the documents directory.
Future<AppSettings> concurrentGetAppSettings(Map<String, dynamic> args) async {
  final encrypter = args['encrypter'] as Encrypter;
  final iv = args['iv'] as IV;

  final documentsPath = args['documentsPath'] as Directory;
  final appSettingsPath = '${documentsPath.path}/settings.txt';

  try {
    final appSettingsJsonBytes = File(appSettingsPath).readAsBytesSync();
    final appSettingsJson = utf8.decode(appSettingsJsonBytes);
    final decrypted = encrypter.decrypt64(appSettingsJson, iv: iv);
    final appSettings = AppSettings.fromJson(jsonDecode(decrypted));
    return appSettings;
  } catch (e) {
    debugPrint(e.toString());
    return AppSettings();
  }
}

/// The [concurrentDeleteChat] function deletes the chat from the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [chat] - the chat to be deleted.
///  * [documentsPath] - the path to the documents directory.
Future<void> concurrentDeleteChat(Map<String, dynamic> args) async {
  final chat = args['chat'] as Chat;
  final documentsPath = args['documentsPath'] as Directory;
  final chatPath = '${documentsPath.path}/chats/chat-${chat.id}.txt';

  try {
    final file = File(chatPath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

/// The [concurrentDeleteImage] function deletes the image from the local storage.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [image] - the image to be deleted.
///  * [documentsPath] - the path to the documents directory.
Future<void> concurrentDeleteImage(Map<String, dynamic> args) async {
  final image = args['image'] as ChatImage;
  final documentsPath = args['documentsPath'] as Directory;
  final imagePath = '${documentsPath.path}/images/image-${image.id}.txt';

  try {
    final file = File(imagePath);
    if (file.existsSync()) {
      file.deleteSync();
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}

/// The [buildAppState] function builds the app state.
/// The [args] parameter defines the arguments for the function.
///
/// The [args] parameter is defined as follows:
///  * [encrypter] - the encrypter for decrypting the app state.
///  * [iv] - the initialization vector for decrypting the app state.
///  * [documentsPath] - the path to the documents directory.
Future<AppState> buildAppState(Map<String, dynamic> args) {
  final chats = concurrentGetChats(args);
  final images = concurrentGetImages(args);
  final appSettings = concurrentGetAppSettings(args);

  return Future.wait([chats, images, appSettings]).then((values) {
    final chatList = values[0] as List<Chat>;
    final imageList = values[1] as List<ChatImage>;
    final appSettings = values[2] as AppSettings;

    for (final chat in chatList) {
      for (final chatMessage in chat.messages) {
        try {
          final image = imageList
              .firstWhere((element) => element.chatMessageId == chatMessage.id);
          chatMessage.imageMessage = image;
        } catch (_) {}
      }
    }

    return AppState(
      chats: chatList,
      settings: appSettings,
    );
  });
}

/// The [concurrentDeleteAllData] function deletes all the data from the local storage.
/// The [documentsPath] parameter defines the path to the documents directory.
Future<void> concurrentDeleteAllData(Directory documentsPath) async {
  try {
    documentsPath.deleteSync(recursive: true);
  } catch (e) {
    debugPrint(e.toString());
  }
}
