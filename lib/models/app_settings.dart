import 'package:flutter/foundation.dart';

enum DallEImageSize {
  small,
  medium,
  large;

  String get apiSize {
    switch (this) {
      case DallEImageSize.small:
        return '256x256';
      case DallEImageSize.medium:
        return '512x512';
      case DallEImageSize.large:
        return '1024x1024';
      default:
        return '1024x1024';
    }
  }

  String get cost {
    switch (this) {
      case DallEImageSize.small:
        return '\$0.016';
      case DallEImageSize.medium:
        return '\$0.018';
      case DallEImageSize.large:
        return '\$0.020';
      default:
        return '\$0.020';
    }
  }
}

class AppSettings {
  String? apiKey;
  String? selectedChatId;
  DallEImageSize dallEImageSize;

  AppSettings({
    this.apiKey,
    this.selectedChatId,
    this.dallEImageSize = DallEImageSize.large,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      apiKey: json['apiKey'],
      selectedChatId: json['selectedChatId'],
      dallEImageSize: DallEImageSize.values.firstWhere(
        (e) => describeEnum(e) == json['dallEImageSize'],
        orElse: () => DallEImageSize.large,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apiKey': apiKey,
      'selectedChatId': selectedChatId,
      'dallEImageSize': describeEnum(dallEImageSize),
    };
  }

  @override
  String toString() {
    return 'AppSettings(apiKey: $apiKey, selectedChatId: $selectedChatId, dallEImageSize: $dallEImageSize)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppSettings &&
        other.runtimeType == runtimeType &&
        other.apiKey == apiKey &&
        other.selectedChatId == selectedChatId &&
        other.dallEImageSize == dallEImageSize;
  }

  @override
  int get hashCode => Object.hash(apiKey, selectedChatId, dallEImageSize);
}
