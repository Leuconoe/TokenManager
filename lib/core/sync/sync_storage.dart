// Platform-injected sync file IO. Windows = file path; Android = SAF document.
// Reads/writes raw encrypted bytes; knows nothing about crypto or merge.

import 'dart:typed_data';

abstract interface class SyncStorage {
  /// Returns the remote blob, or null if it doesn't exist yet.
  Future<Uint8List?> read();

  /// Overwrites the remote blob.
  Future<void> write(Uint8List bytes);

  /// Whether a sync target is configured (folder/file chosen).
  bool get isConfigured;
}
