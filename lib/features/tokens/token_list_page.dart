// Design Ref: §5.4 TokenListPage — list, status filter chips, sort, FAB.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/crypto/passphrase_crypto.dart' show BackupAuthException;
import '../../core/domain/token_entry.dart';
import '../../core/domain/token_status.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/status_badge.dart';
import '../backup/backup_page.dart';
import '../settings/settings_page.dart';
import 'data/token_repository.dart';
import 'token_edit_page.dart';
import 'token_providers.dart';

/// Search query for the list (title / site / note). Session-scoped.
final _searchProvider = StateProvider.autoDispose<String>((_) => '');

class TokenListPage extends ConsumerWidget {
  const TokenListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final asyncState = ref.watch(tokenListProvider);
    final notifier = ref.read(tokenListProvider.notifier);
    final curSort = asyncState.valueOrNull?.sort ?? TokenSort.expiry;
    final asc = asyncState.valueOrNull?.ascending ?? true;

    PopupMenuItem<TokenSort> sortItem(TokenSort s, String label) => PopupMenuItem(
          value: s,
          child: Row(children: [
            Icon(s == curSort ? Icons.check : null, size: 18),
            const SizedBox(width: 8),
            Text(label),
          ]),
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(l.listTitle),
        actions: [
          PopupMenuButton<TokenSort>(
            icon: const Icon(Icons.sort),
            tooltip: l.sortBy,
            onSelected: notifier.setSort,
            itemBuilder: (_) => [
              sortItem(TokenSort.expiry, l.sortExpiry),
              sortItem(TokenSort.created, l.sortCreated),
              sortItem(TokenSort.name, l.sortName),
              sortItem(TokenSort.site, l.sortSite),
            ],
          ),
          IconButton(
            icon: Icon(asc ? Icons.arrow_upward : Icons.arrow_downward),
            tooltip: asc ? l.sortAsc : l.sortDesc,
            onPressed: () => notifier.toggleSortDir(),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: l.syncNowAction,
            onPressed: () => _menuSync(context, ref, l),
          ),
          IconButton(
            icon: const Icon(Icons.backup_outlined),
            tooltip: l.tooltipBackup,
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const BackupPage())),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search, size: 20),
                hintText: l.searchHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) => ref.read(_searchProvider.notifier).state = v,
            ),
          ),
          _FilterChips(
            selected: asyncState.valueOrNull?.filter,
            onSelected: notifier.setFilter,
          ),
          Expanded(
            child: asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (s) {
                final q = ref.watch(_searchProvider).trim().toLowerCase();
                final shown = q.isEmpty
                    ? s.entries
                    : s.entries.where((e) {
                        return e.serviceName.toLowerCase().contains(q) ||
                            e.url.toLowerCase().contains(q) ||
                            e.note.toLowerCase().contains(q);
                      }).toList();
                if (s.entries.isEmpty) return const _EmptyState();
                if (shown.isEmpty) {
                  return Center(child: Text(l.searchNoResults));
                }
                return ListView.separated(
                  itemCount: shown.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) =>
                      _TokenTile(entry: shown[i], leadDays: s.leadDays),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TokenEditPage())),
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// Quick sync from the main menu. Mirrors Settings' "Sync now", incl. the
/// passphrase-mismatch distinction.
Future<void> _menuSync(
    BuildContext context, WidgetRef ref, AppLocalizations l) async {
  final m = ScaffoldMessenger.of(context);
  m.showSnackBar(SnackBar(
      content: Text(l.syncInProgress), duration: const Duration(seconds: 30)));
  try {
    final n = await ref.read(syncControllerProvider).syncNow();
    if (!context.mounted) return;
    m.hideCurrentSnackBar();
    if (n == null) {
      m.showSnackBar(SnackBar(content: Text(l.syncNeedSetup)));
      return;
    }
    ref.invalidate(tokenListProvider);
    m.showSnackBar(SnackBar(content: Text(l.syncResultDone(n))));
  } on BackupAuthException {
    if (!context.mounted) return;
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(content: Text(l.syncPassMismatchTitle)));
  } catch (_) {
    if (!context.mounted) return;
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(content: Text(l.syncResultFailed)));
  }
}

class _FilterChips extends StatelessWidget {
  final TokenStatus? selected;
  final ValueChanged<TokenStatus?> onSelected;
  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget chip(String label, TokenStatus? value) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FilterChip(
            label: Text(label),
            selected: selected == value,
            onSelected: (_) => onSelected(value),
          ),
        );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(children: [
        chip(l.filterAll, null),
        chip(l.statusSoon, TokenStatus.expiringSoon),
        chip(l.statusExpired, TokenStatus.expired),
        chip(l.statusNoExpiry, TokenStatus.noExpiry),
        chip(l.statusValid, TokenStatus.valid),
      ]),
    );
  }
}

class _TokenTile extends StatelessWidget {
  final TokenEntry entry;
  final int leadDays;
  const _TokenTile({required this.entry, this.leadDays = 14});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = entry.statusAt(now, soonDays: leadDays);
    return ListTile(
      title: Text(entry.serviceName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.url.isNotEmpty)
            Row(
              children: [
                Expanded(
                  child: Text(entry.url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.indigo, fontSize: 12)),
                ),
                InkWell(
                  onTap: () => _openUrl(entry.url),
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.open_in_new, size: 16, color: Colors.indigo),
                  ),
                ),
              ],
            ),
          Text(_subtitle(context, entry, now)),
        ],
      ),
      trailing: StatusBadge(status),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TokenEditPage(existing: entry))),
    );
  }

  Future<void> _openUrl(String raw) async {
    var u = raw.trim();
    if (!u.startsWith('http://') && !u.startsWith('https://')) u = 'https://$u';
    final uri = Uri.tryParse(u);
    if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _subtitle(BuildContext context, TokenEntry e, DateTime now) {
    final l = AppLocalizations.of(context);
    if (e.expiresAt == null) return l.subtitleNoExpiry;
    final d = e.expiresAt!;
    final days = d.difference(now).inDays;
    final ymd =
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    if (days < 0) return l.subtitleExpired(ymd);
    return l.subtitleDday(days, ymd);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
          const SizedBox(height: 12),
          Text(l.emptyTitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(l.emptyHint,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
