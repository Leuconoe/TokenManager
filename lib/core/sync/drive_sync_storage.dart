// Google Drive SyncStorage — stores the single encrypted blob in the hidden
// appDataFolder (app-scoped, invisible to the user's Drive). Ciphertext only.

import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart' as drive;

import 'sync_storage.dart';

class DriveSyncStorage implements SyncStorage {
  final drive.DriveApi api;
  static const fileName = 'tokenmanager-sync.tmbk';

  DriveSyncStorage(this.api);

  @override
  bool get isConfigured => true; // an authed DriveApi means it's ready

  Future<String?> _fileId() async {
    final res = await api.files.list(
      spaces: 'appDataFolder',
      q: "name = '$fileName'",
      $fields: 'files(id)',
    );
    final files = res.files;
    return (files != null && files.isNotEmpty) ? files.first.id : null;
  }

  @override
  Future<Uint8List?> read() async {
    final id = await _fileId();
    if (id == null) return null;
    final media = await api.files.get(
      id,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final chunks = <int>[];
    await for (final c in media.stream) {
      chunks.addAll(c);
    }
    return Uint8List.fromList(chunks);
  }

  @override
  Future<void> write(Uint8List bytes) async {
    final media =
        drive.Media(Stream.value(bytes), bytes.length, contentType: 'application/octet-stream');
    final id = await _fileId();
    if (id == null) {
      final f = drive.File()
        ..name = fileName
        ..parents = ['appDataFolder'];
      await api.files.create(f, uploadMedia: media);
    } else {
      await api.files.update(drive.File(), id, uploadMedia: media);
    }
  }
}
