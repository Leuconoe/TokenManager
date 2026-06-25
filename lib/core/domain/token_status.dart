// Design Ref: §3.1 — derived token lifecycle status (pure domain logic, no deps).

/// Lifecycle status of a token, derived from its expiry date.
enum TokenStatus {
  /// Has an expiry date comfortably in the future.
  valid,

  /// Expires within [defaultSoonDays] (default 14) days.
  expiringSoon,

  /// Expiry date has passed (or is exactly now).
  expired,

  /// No expiry date set — security-warning target.
  noExpiry;

  /// Default window (days) for the "expiring soon" warning.
  static const int defaultSoonDays = 14;

  /// Computes status for [expiresAt] relative to [now].
  ///
  /// - `null` expiry        -> [noExpiry]
  /// - not after `now`      -> [expired]
  /// - within [soonDays]    -> [expiringSoon]
  /// - otherwise            -> [valid]
  static TokenStatus compute(
    DateTime? expiresAt,
    DateTime now, {
    int soonDays = defaultSoonDays,
  }) {
    if (expiresAt == null) return TokenStatus.noExpiry;
    if (!expiresAt.isAfter(now)) return TokenStatus.expired;
    if (expiresAt.difference(now).inDays <= soonDays) {
      return TokenStatus.expiringSoon;
    }
    return TokenStatus.valid;
  }
}
