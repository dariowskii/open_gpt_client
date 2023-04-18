import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    );
  }

  /// The [toJson] method returns the JSON representation of the message that can be saved in the local storage.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'role': senderRole.value,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
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
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(senderRole, content, id, createdAt);
  }
}

/// The [Chat] class defines a chat.
class Chat {
  /// The [id] property defines the id of the chat.
  final String id;

  /// The [title] property defines the title of the chat.
  final String title;

  /// The [messages] property defines the messages of the chat.
  final List<ChatMessage> messages;

  /// The [contextMessages] property defines the messages of the chat that can be sent to the OpenAI API.
  final List<ChatMessage> contextMessages;

  const Chat({
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
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
          .toList(),
      contextMessages: (json['contextMessages'] as List<dynamic>)
          .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
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
