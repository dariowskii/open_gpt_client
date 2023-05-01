import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_gpt_client/models/app_settings.dart';
import 'package:open_gpt_client/widgets/chat_message_ui.dart';

/// The [MessageSenderRole] enum defines the role of the sender of a message.
enum MessageSenderRole {
  user,
  assistant,
  system;

  String get value {
    switch (this) {
      case MessageSenderRole.user:
        return 'user';
      case MessageSenderRole.assistant:
        return 'assistant';
      case MessageSenderRole.system:
        return 'system';
    }
  }
}

/// The [MessageType] enum defines the type of a message.
enum MessageType { text, image }

/// The [ChatMessage] class defines a message in a chat.
class ChatMessage {
  /// The [senderRole] property defines the role of the sender of the message.
  final MessageSenderRole senderRole;

  /// The [uniqueKeyUI] property defines the unique key of the UI of the message.
  final GlobalKey<ChatMessageUIState>? uniqueKeyUI;

  /// The [id] property defines the id of the message.
  final String id;

  /// The [createdAt] property defines the date and time of the creation of the message.
  final DateTime createdAt;

  /// The [isLoadingResponse] property defines if the message is waiting for a response.
  bool isLoadingResponse;

  /// The [wasInError] property defines if the message was in error.
  bool wasInError;

  /// The [content] property defines the content of the message.
  String content;

  /// The [messageType] property defines the type of the message.
  final MessageType messageType;

  /// The [imageMessage] property defines the image message.
  ChatImage? imageMessage;

  /// The [fromMe] getter defines if the message is from the user.
  bool get fromMe => senderRole == MessageSenderRole.user;

  ChatMessage({
    this.uniqueKeyUI,
    this.senderRole = MessageSenderRole.user,
    this.isLoadingResponse = false,
    this.wasInError = false,
    DateTime? createdAt,
    required this.id,
    required this.content,
    this.messageType = MessageType.text,
    this.imageMessage,
  }) : createdAt = createdAt ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      senderRole: MessageSenderRole.values.firstWhere(
        (e) => e.value == json['role'],
      ),
      content: json['content'] as String,
      wasInError: json['wasInError'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      messageType: MessageType.values.firstWhere(
        (e) => describeEnum(e) == json['messageType'],
        orElse: () => MessageType.text,
      ),
    );
  }

  /// The [toJson] method returns the JSON representation of the message that can be saved in the local storage.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'role': senderRole.value,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'messageType': describeEnum(messageType),
    };
    if (wasInError) {
      json['wasInError'] = wasInError;
    }
    return json;
  }

  /// The [toContextMessageJson] method returns the JSON representation of the message that can be sent to the OpenAI API.
  Map<String, dynamic> toContextMessageJson() {
    return {
      'role': senderRole.value,
      'content': content,
    };
  }

  @override
  String toString() {
    return 'ChatMessage(senderRole: $senderRole, content: $content)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatMessage &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.senderRole == senderRole &&
        other.content == content &&
        other.wasInError == wasInError &&
        other.createdAt == createdAt &&
        other.messageType == messageType &&
        other.imageMessage == imageMessage;
  }

  @override
  int get hashCode {
    return Object.hash(senderRole, content, id, wasInError, createdAt,
        messageType, imageMessage);
  }
}

class ChatImage {
  /// The [id] property defines the id of the image.
  final String id;

  /// The [prompt] property defines the prompt for generating the image.
  final String prompt;

  /// The [size] property defines the size of the image.
  final DallEImageSize size;

  /// The [imageBytes] property defines the bytes of the image of the message.
  Uint8List? imageBytes;

  /// The [imageSize] property defines the size of the image of the message.
  String? imageSize;

  /// The [chatMessageId] property defines the id of the chat message.
  String chatMessageId;

  ChatImage({
    required this.id,
    required this.prompt,
    required this.size,
    this.imageBytes,
    this.imageSize,
    this.chatMessageId = '',
  });

  factory ChatImage.fromJson(Map<String, dynamic> json) {
    return ChatImage(
      id: json['id'],
      prompt: json['prompt'],
      size: DallEImageSize.values.firstWhere(
        (e) => describeEnum(e) == json['size'],
        orElse: () => DallEImageSize.large,
      ),
      imageBytes: json['imageBytes'] != null
          ? base64Decode(json['imageBytes'])
          : null,
      imageSize: json['imageSize'],
      chatMessageId: json['chatMessageId'],
    );
  }

  /// The [toJson] method returns the JSON representation of the image that can be saved in the local storage.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'prompt': prompt,
      'size': describeEnum(size),
      'chatMessageId': chatMessageId,
    };
    if (imageBytes != null) {
      json['imageBytes'] = base64Encode(imageBytes!);
    }
    if (imageSize != null) {
      json['imageSize'] = imageSize;
    }
    return json;
  }

  @override
  String toString() {
    return 'ChatImage(id: $id, prompt: $prompt, size: $size, chatMessageId: $chatMessageId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ChatImage &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.prompt == prompt &&
        other.size == size &&
        other.imageBytes == imageBytes &&
        other.imageSize == imageSize &&
        other.chatMessageId == chatMessageId;
  }

  @override
  int get hashCode {
    return Object.hash(id, prompt, size, imageBytes, imageSize, chatMessageId);
  }
}

/// The [Chat] class defines a chat.
class Chat {
  /// The [id] property defines the id of the chat.
  final String id;

  /// The [title] property defines the title of the chat.
  String title;

  /// The [messages] property defines the messages of the chat.
  final List<ChatMessage> messages;

  /// The [contextMessages] property defines the messages of the chat that can be sent to the OpenAI API.
  final List<ChatMessage> contextMessages;

  Chat({
    required this.id,
    required this.title,
    required this.messages,
    required this.contextMessages,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      title: json['title'] as String,
      messages: (json['messages'] as List<dynamic>)
          .map((message) => ChatMessage.fromJson(message))
          .toList(),
      contextMessages: (json['contextMessages'] as List<dynamic>)
          .map((message) => ChatMessage.fromJson(message))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'Chat(id: $id, title: $title, messages: $messages)';
  }

  /// The [contextMessagesJson] method returns the JSON representation of the messages that can be sent to the OpenAI API.
  List<Map<String, dynamic>> contextMessagesJson() {
    return contextMessages.map((e) => e.toContextMessageJson()).toList();
  }

  /// The [toJson] method returns the JSON representation of the chat that can be saved in the local storage.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((e) => e.toJson()).toList(),
      'contextMessages': contextMessages.map((e) => e.toJson()).toList(),
    };
  }

  /// The [images] getter returns the images of the chat.
  List<ChatImage> get images {
    return messages
        .where((message) => message.imageMessage != null)
        .map((message) => message.imageMessage!)
        .toList();
  }

  Chat copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    List<ChatMessage>? contextMessages,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      contextMessages: contextMessages ?? this.contextMessages,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Chat &&
        other.runtimeType == runtimeType &&
        other.id == id &&
        other.title == title &&
        listEquals(other.messages, messages) &&
        listEquals(other.contextMessages, contextMessages);
  }

  @override
  int get hashCode {
    return Object.hash(id, title, messages, contextMessages);
  }
}
