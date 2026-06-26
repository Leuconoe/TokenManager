// Desktop folder SyncStorage — writes the encrypted blob into a user-chosen
// folder (typically a Drive/OneDrive/Dropbox synced folder). Atomic write via
// temp + rename so the cloud client never sees a half-written file.

import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'sync_storage.dart';

class FolderSyncStorage implements SyncStorage {
  final String? folderPath;
  static const fileName = 'tokenmanager-sync.tmbk';

  FolderSyncStorage(this.folderPath);

  String? get _path =>
      (folderPath == null || folderPath!.isEmpty) ? null : p.join(folderPath!, fileName);

  @override
  bool get isConfigured => _path != null;

  @override
  Future<Uint8List?> read() async {
    final path = _path;
    if (path == null) return null;
    final f = File(path);
    if (!await f.exists()) return null;
    return f.readAsBytes();
  }

  @override
  Future<void> write(Uint8List bytes) async {
    final path = _path;
    if (path == null) throw StateError('sync folder not configured');
    final tmp = File('$path.tmp');
    await tmp.writeAsBytes(bytes, flush: true);
    if (await File(path).exists()) await File(path).delete();
    await tmp.rename(path); // atomic on the same filesystem
  }
}
