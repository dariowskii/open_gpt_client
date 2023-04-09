import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:open_gpt_client/widgets/chat_message_ui.dart';

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

class ChatMessage {
  final MessageSenderRole senderRole;
  final GlobalKey<ChatMessageUIState>? uniqueKeyUI;
  final String id;
  final DateTime createdAt;

  bool isLoadingResponse;
  String content;

  bool get fromMe => senderRole == MessageSenderRole.user;

  ChatMessage({
    this.uniqueKeyUI,
    this.senderRole = MessageSenderRole.user,
    this.isLoadingResponse = false,
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
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': senderRole.value,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }

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
        other.content == content;
  }

  @override
  int get hashCode {
    return Object.hash(senderRole, content, id);
  }
}

class Chat {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final List<ChatMessage> contextMessages;

  const Chat({
    required this.id,
    required this.title,
    required this.messages,
    required this.contextMessages,
  });

  @override
  String toString() {
    return 'Chat(id: $id, title: $title, messages: $messages)';
  }

  List<Map<String, dynamic>> contextMessagesJson() {
    return contextMessages.map((e) => e.toContextMessageJson()).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((e) => e.toJson()).toList(),
      'contextMessages': contextMessages.map((e) => e.toJson()).toList(),
    };
  }

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
