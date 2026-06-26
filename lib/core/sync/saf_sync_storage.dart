// Android SAF SyncStorage — reads/writes the encrypted blob inside a
// user-picked document tree (a Drive/OneDrive/etc folder exposed via SAF).
// The tree URI carries a persisted permission so it survives restarts.

import 'dart:typed_data';

import 'package:saf_stream/saf_stream.dart';
import 'package:saf_util/saf_util.dart';

import 'sync_storage.dart';

class SafSyncStorage implements SyncStorage {
  final String? treeUri;
  static const fileName = 'tokenmanager-sync.tmbk';

  final _saf = SafUtil();
  final _stream = SafStream();

  SafSyncStorage(this.treeUri);

  @override
  bool get isConfigured => treeUri != null && treeUri!.isNotEmpty;

  @override
  Future<Uint8List?> read() async {
    if (treeUri == null) return null;
    final child = await _saf.child(treeUri!, [fileName]);
    if (child == null) return null;
    return _stream.readFileBytes(child.uri);
  }

  @override
  Future<void> write(Uint8List bytes) async {
    if (treeUri == null) throw StateError('sync tree not configured');
    // SAF provider overwrites the document content in place.
    await _stream.writeFileBytes(
      treeUri!,
      fileName,
      'application/octet-stream',
      bytes,
      overwrite: true,
    );
  }
}
