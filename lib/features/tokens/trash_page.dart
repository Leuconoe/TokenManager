// Trash — lists tombstoned (soft-deleted) entries with restore, per-item
// permanent purge, and bulk purge-all. Old tombstones are auto-purged after a
// retention window (see TokenRepository.purgeDeletedBefore), so this is mostly
// for early cleanup or restoring an accidental delete.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/token_entry.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import 'token_providers.dart';

final _deletedProvider = FutureProvider.autoDispose<List<TokenEntry>>(
    (ref) => ref.watch(tokenRepositoryProvider).listDeleted());

class TrashPage extends ConsumerWidget {
  const TrashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final async = ref.watch(_deletedProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.trashTitle),
        actions: [
          if ((async.valueOrNull ?? const []).isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_forever),
              tooltip: l.trashPurgeAll,
              onPressed: () => _purgeAll(context, ref, l),
            ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (items) => items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.trashEmpty, textAlign: TextAlign.center),
                ),
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(l.trashHint,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final e = items[i];
                        return ListTile(
                          title: Text(e.serviceName,
                              maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: e.deletedAt == null
                              ? null
                              : Text(l.trashDeletedOn(
                                  '${e.deletedAt!.year}-${e.deletedAt!.month.toString().padLeft(2, '0')}-${e.deletedAt!.day.toString().padLeft(2, '0')}')),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.restore_from_trash),
                                tooltip: l.trashRestore,
                                onPressed: () async {
                                  await ref
                                      .read(tokenRepositoryProvider)
                                      .restore(e.id);
                                  ref.invalidate(_deletedProvider);
                                  ref.invalidate(tokenListProvider);
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_forever_outlined),
                                tooltip: l.trashPurge,
                                onPressed: () async {
                                  await ref
                                      .read(tokenRepositoryProvider)
                                      .purge(e.id);
                                  await ref
                                      .read(syncControllerProvider)
                                      .purgeRemoteTombstones(ids: {e.id});
                                  ref.invalidate(_deletedProvider);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _purgeAll(
      BuildContext context, WidgetRef ref, AppLocalizations l) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.trashPurgeAll),
        content: Text(l.trashPurgeAllConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.actionCancel)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.trashPurge)),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(tokenRepositoryProvider).purgeAllDeleted();
      await ref.read(syncControllerProvider).purgeRemoteTombstones();
      ref.invalidate(_deletedProvider);
    }
  }
}
