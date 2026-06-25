// Design Ref: §5.4 TokenListPage — list, status filter chips, sort, FAB.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/token_entry.dart';
import '../../core/domain/token_status.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/status_badge.dart';
import '../backup/backup_page.dart';
import '../settings/settings_page.dart';
import 'data/token_repository.dart';
import 'token_edit_page.dart';
import 'token_providers.dart';

class TokenListPage extends ConsumerWidget {
  const TokenListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final asyncState = ref.watch(tokenListProvider);
    final notifier = ref.read(tokenListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.listTitle),
        actions: [
          PopupMenuButton<TokenSort>(
            icon: const Icon(Icons.sort),
            onSelected: notifier.setSort,
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: TokenSort.expirySoonest, child: Text(l.sortExpiry)),
              PopupMenuItem(
                  value: TokenSort.serviceName, child: Text(l.sortName)),
              PopupMenuItem(
                  value: TokenSort.recentlyUpdated, child: Text(l.sortUpdated)),
            ],
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
          _FilterChips(
            selected: asyncState.valueOrNull?.filter,
            onSelected: notifier.setFilter,
          ),
          Expanded(
            child: asyncState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류: $e')),
              data: (s) => s.entries.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      itemCount: s.entries.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) => _TokenTile(entry: s.entries[i]),
                    ),
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
  const _TokenTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = entry.statusAt(now);
    return ListTile(
      title: Text(entry.serviceName,
          maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (entry.url.isNotEmpty)
            Text(entry.url,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.indigo, fontSize: 12)),
          Text(_subtitle(context, entry, now)),
        ],
      ),
      trailing: StatusBadge(status),
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => TokenEditPage(existing: entry))),
    );
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
