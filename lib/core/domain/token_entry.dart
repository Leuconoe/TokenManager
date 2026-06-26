// Design Ref: §3.1 — TokenEntry entity.
// SECURITY: there is intentionally NO token-value field. This app stores
// metadata only (Plan SC: metadata-only). The `note` field must never hold a token.

import 'token_status.dart';

class TokenEntry {
  final String id; // UUID v4
  final String serviceName; // required, e.g. "GitHub PAT - CI 배포용"
  final String url; // optional service/console URL (where the token is managed)
  final DateTime? issuedAt; // optional
  final DateTime? expiresAt; // optional; null => no expiry (warning target)
  final String note; // free memo; token values forbidden (warned, not blocked)
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt; // tombstone — soft delete for sync propagation

  const TokenEntry({
    required this.id,
    required this.serviceName,
    required this.createdAt,
    required this.updatedAt,
    this.url = '',
    this.issuedAt,
    this.expiresAt,
    this.note = '',
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  /// Derived lifecycle status at [now].
  TokenStatus statusAt(DateTime now, {int soonDays = TokenStatus.defaultSoonDays}) =>
      TokenStatus.compute(expiresAt, now, soonDays: soonDays);

  TokenEntry copyWith({
    String? serviceName,
    String? url,
    DateTime? issuedAt,
    bool clearIssuedAt = false,
    DateTime? expiresAt,
    bool clearExpiresAt = false,
    String? note,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return TokenEntry(
      id: id,
      serviceName: serviceName ?? this.serviceName,
      url: url ?? this.url,
      issuedAt: clearIssuedAt ? null : (issuedAt ?? this.issuedAt),
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      note: note ?? this.note,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  // --- Backup (de)serialization. Used by BackupRepository (module-3). ---

  Map<String, dynamic> toJson() => {
        'id': id,
        'serviceName': serviceName,
        'url': url,
        'issuedAt': issuedAt?.millisecondsSinceEpoch,
        'expiresAt': expiresAt?.millisecondsSinceEpoch,
        'note': note,
        'createdAt': createdAt.millisecondsSinceEpoch,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'deletedAt': deletedAt?.millisecondsSinceEpoch,
      };

  factory TokenEntry.fromJson(Map<String, dynamic> json) {
    DateTime? ms(dynamic v) =>
        v == null ? null : DateTime.fromMillisecondsSinceEpoch(v as int);
    return TokenEntry(
      id: json['id'] as String,
      serviceName: json['serviceName'] as String,
      url: (json['url'] as String?) ?? '', // backward compatible
      issuedAt: ms(json['issuedAt']),
      expiresAt: ms(json['expiresAt']),
      note: (json['note'] as String?) ?? '',
      createdAt: ms(json['createdAt'])!,
      updatedAt: ms(json['updatedAt'])!,
      deletedAt: ms(json['deletedAt']),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is TokenEntry &&
      other.id == id &&
      other.serviceName == serviceName &&
      other.url == url &&
      other.issuedAt == issuedAt &&
      other.expiresAt == expiresAt &&
      other.note == note &&
      other.createdAt == createdAt &&
      other.updatedAt == updatedAt &&
      other.deletedAt == deletedAt;

  @override
  int get hashCode => Object.hash(id, serviceName, url, issuedAt, expiresAt,
      note, createdAt, updatedAt, deletedAt);
}
