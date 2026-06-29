// Design Ref: §10.4 — Riverpod state for the token list (sort + status filter).

import 'dart:async' show unawaited;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/domain/token_entry.dart';
import '../../core/domain/token_status.dart';
import '../../core/providers.dart';
import 'data/token_repository.dart';

class TokenListState {
  final List<TokenEntry> entries;
  final TokenSort sort;
  final bool ascending;
  final TokenStatus? filter; // null => all
  final int leadDays; // expiry-soon window from Settings
  const TokenListState({
    required this.entries,
    this.sort = TokenSort.expiry,
    this.ascending = true,
    this.filter,
    this.leadDays = 14,
  });
}

final tokenListProvider =
    AsyncNotifierProvider<TokenListNotifier, TokenListState>(
        TokenListNotifier.new);

class TokenListNotifier extends AsyncNotifier<TokenListState> {
  TokenSort _sort = TokenSort.expiry;
  bool _asc = true;
  TokenStatus? _filter;
  bool _sortLoaded = false;

  @override
  Future<TokenListState> build() => _load();

  Future<TokenListState> _load() async {
    final repo = ref.read(tokenRepositoryProvider);
    final settings = ref.read(settingsRepositoryProvider);
    if (!_sortLoaded) {
      // Restore the persisted sort once, on first load.
      final k = await settings.getSortKey();
      _sort = TokenSort.values.firstWhere((e) => e.name == k,
          orElse: () => TokenSort.expiry);
      _asc = await settings.getSortAsc();
      _sortLoaded = true;
    }
    final lead = (await settings.getExpiryLead()).days;
    final all = await repo.list(sort: _sort, ascending: _asc);
    final now = DateTime.now();
    final filtered = _filter == null
        ? all
        : all.where((e) => e.statusAt(now, soonDays: lead) == _filter).toList();
    return TokenListState(
        entries: filtered,
        sort: _sort,
        ascending: _asc,
        filter: _filter,
        leadDays: lead);
  }

  Future<void> _refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> setSort(TokenSort sort) async {
    _sort = sort;
    await ref.read(settingsRepositoryProvider).setSortKey(sort.name);
    return _refresh();
  }

  Future<void> toggleSortDir() async {
    _asc = !_asc;
    await ref.read(settingsRepositoryProvider).setSortAsc(_asc);
    return _refresh();
  }

  Future<void> setFilter(TokenStatus? filter) {
    _filter = filter;
    return _refresh();
  }

  Future<void> save(TokenEntry entry) async {
    await ref.read(tokenRepositoryProvider).upsert(entry);
    await _refresh();
    unawaited(ref.read(syncControllerProvider).syncQuietly()); // best-effort push
  }

  Future<void> remove(String id) async {
    await ref.read(tokenRepositoryProvider).delete(id);
    await _refresh();
    unawaited(ref.read(syncControllerProvider).syncQuietly());
  }
}
