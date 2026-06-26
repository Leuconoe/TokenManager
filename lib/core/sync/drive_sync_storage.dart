// Google Drive SyncStorage — stores the single encrypted blob in a VISIBLE
// "TokenManager" folder in My Drive (drive.file scope). Sharing one Cloud
// project, all clients (Android, Windows, extension) read/write this same file,
// and the user can see it. Ciphertext only.

import 'dart:typed_data';

import 'package:googleapis/drive/v3.dart' as drive;

import '../debug/debug_log.dart';
import 'sync_storage.dart';

class DriveSyncStorage implements SyncStorage {
  final drive.DriveApi api;
  static const fileName = 'tokenmanager-sync.tmbk';
  static const folderName = 'TokenManager';
  static const _folderMime = 'application/vnd.google-apps.folder';

  DriveSyncStorage(this.api);

  @override
  bool get isConfigured => true; // an authed DriveApi means it's ready

  /// Find (or create) the visible TokenManager folder; returns its id.
  Future<String> _folderId() async {
    final res = await api.files.list(
      q: "name = '$folderName' and mimeType = '$_folderMime' and trashed = false",
      $fields: 'files(id)',
    );
    final files = res.files;
    if (files != null && files.isNotEmpty) {
      dlog('drive: folder found ${files.first.id}');
      return files.first.id!;
    }
    final created = await api.files.create(
      drive.File()
        ..name = folderName
        ..mimeType = _folderMime,
    );
    dlog('drive: folder created ${created.id}');
    return created.id!;
  }

  Future<String?> _fileId(String folderId) async {
    final res = await api.files.list(
      q: "name = '$fileName' and '$folderId' in parents and trashed = false",
      $fields: 'files(id)',
    );
    final files = res.files;
    return (files != null && files.isNotEmpty) ? files.first.id : null;
  }

  @override
  Future<Uint8List?> read() async {
    final folderId = await _folderId();
    final id = await _fileId(folderId);
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
    final folderId = await _folderId();
    final media =
        drive.Media(Stream.value(bytes), bytes.length, contentType: 'application/octet-stream');
    final id = await _fileId(folderId);
    if (id == null) {
      final f = drive.File()
        ..name = fileName
        ..parents = [folderId];
      await api.files.create(f, uploadMedia: media);
    } else {
      await api.files.update(drive.File(), id, uploadMedia: media);
    }
  }
}
