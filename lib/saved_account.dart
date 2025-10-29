import 'dart:convert';

/// A model class to represent a user account saved locally for quick sign-in.
class SavedAccount {
  final String providerId; // e.g., 'google.com', 'microsoft.com'
  final String email;
  final String displayName;
  final String? photoUrl;

  SavedAccount({
    required this.providerId,
    required this.email,
    required this.displayName,
    this.photoUrl,
  });

  /// Creates a `SavedAccount` instance from a JSON map.
  factory SavedAccount.fromJson(Map<String, dynamic> json) {
    return SavedAccount(
      providerId: json['providerId'],
      email: json['email'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
    );
  }

  /// Converts the `SavedAccount` instance to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  /// Encodes the `SavedAccount` instance to a JSON string.
  String toJsonString() => json.encode(toJson());

  /// Decodes a `SavedAccount` instance from a JSON string.
  static SavedAccount fromJsonString(String jsonString) {
    return SavedAccount.fromJson(json.decode(jsonString));
  }
}
